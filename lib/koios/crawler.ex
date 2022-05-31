defmodule Koios.Crawler do
  use GenServer, restart: :transient
  alias Koios.CrawlRequest

  import Koios.Util.UrlUtil

  @spec start_link(Koios.CrawlerSpec.t()) :: {:ok, pid}
  def start_link(config, opts\\[]) do
    GenServer.start_link(__MODULE__, config, opts)
  end

  @spec statistics(pid) :: %{
    crawled_pages: integer,
    queued_urls: integer,
    running_tasks: integer,
    maximum_tasks: integer,
    start_url: String.t(),
    start_time: DateTime.t(),
    request_last_minute: integer,
    discarded_links: integer,
  }
  def statistics(crawler) do
    GenServer.call(crawler, :statistics)
  end

  @impl true
  def init(config) do

    open_urls = :queue.new
    open_urls = :queue.in(%CrawlRequest{url: config.url}, open_urls)

    schedule_work()
    {:ok, %{
      max_tasks: config.max_tasks,
      caller: config.caller,
      visited_pages: MapSet.new([config.url]),
      open_tasks: MapSet.new(),
      open_urls: open_urls,
      crawler: self(),
      constraints: config.constraints,
      start_url: config.url,
      start_time: DateTime.utc_now(),
      discarded_links: 0,
      request_last_minute: [],
    }}
  end

  @impl true
  def handle_info(
    :schedule_work,
    context = %{
      max_tasks: max_tasks,
      open_tasks: open_tasks,
      open_urls: open_urls,
      caller: caller,
    }
  ) do
    # create new tasks from open_urls
    if MapSet.size(open_tasks) < max_tasks do
      case :queue.out(open_urls) do
        {{:value, req}, rem_urls} ->
          new_task = Task.async(
            fn -> crawl_page(req, context) end
          )
          schedule_work()
          {:noreply, %{
            context
            | open_tasks: MapSet.put(open_tasks, new_task.ref), open_urls: rem_urls
          }}
        {:empty, _} ->
          if MapSet.size(open_tasks) == 0 do
            # no more urls, no more tasks -> we are done
            send(caller, {:done})
            {:stop, :normal, context}
          else
            {:noreply, context}
          end
      end
    else
      {:noreply, context}
    end
  end

  @impl true
  def handle_info({_ref, _result}, context) do
    {:noreply, context}
  end

  @impl true
  def handle_info(
    {:DOWN, ref, _, _, _reason},
    context = %{open_tasks: open_tasks, request_last_minute: request_last_minute}
  ) do
    schedule_work()
    {:noreply, %{
      context
      | open_tasks: MapSet.delete(open_tasks, ref),
      request_last_minute: Enum.filter(
        [ DateTime.utc_now() | request_last_minute ],
        &(DateTime.compare(&1 |> DateTime.add(60, :second), (DateTime.utc_now())) == :gt)
      )
    }}
  end

  @impl true
  def handle_cast(
    {:new_url, %CrawlRequest{url: url, depth: depth, source: source}},
    context = %{
      visited_pages: visited_pages,
      open_urls: open_urls,
      constraints: constraints,
      discarded_links: discarded_links,
    }
  ) do
    unless url == nil or MapSet.member?(visited_pages, url) do
      new_req = %CrawlRequest{url: url, depth: depth, source: source}
      # TODO: add constraints
      if Enum.all?(Enum.map(constraints, &(check_constraint(&1, new_req)))) do
        new_open_urls = :queue.in(new_req, open_urls)
        schedule_work()
        {:noreply, %{
          context
          | visited_pages: MapSet.put(visited_pages, url), open_urls: new_open_urls
        }}
      else
        {:noreply, %{
          context
          | visited_pages: MapSet.put(visited_pages, url),
          discarded_links: discarded_links + 1
        }}
      end
    else
      {:noreply, context}
    end
  end

  @impl true
  def handle_call(:statistics, _from, context) do
    {:reply, %{
      crawled_pages: MapSet.size(context.visited_pages),
      queued_urls: :queue.len(context.open_urls),
      running_tasks: MapSet.size(context.open_tasks),
      maximum_tasks: context.max_tasks,
      start_url: context.start_url,
      start_time: context.start_time,
      request_last_minute: Enum.count(context.request_last_minute),
      discarded_links: context.discarded_links,
    }, context}
  end

  defp check_constraint({constraint, params}, req) do
    constraint.valid?(params, req)
  end

  defp schedule_work() do
    send(self(), :schedule_work)
  end

  defp download_page(url) do
    resp = Koios.RetrieverRegistry.get_retriever(url)
      |> Koios.Retriever.get_page(url)
    case resp do
      # got content
      {:ok, content} ->
        parser_result = Floki.parse_document(content)
        case parser_result do
          # successfully parsed
          {:ok, document} -> {:ok, {content, document}}
          # failed to parse
          {:error, err} -> {:error, err}
        end
      {:error, err} -> {:error, err}
    end
  end

  defp crawl_page(
    crawl_request = %CrawlRequest{url: url},
    %{caller: caller, crawler: crawler}
  ) do
    case download_page(url) do
      {:ok, {raw, document}} ->
        # send data to caller
        send(caller, {:found, {raw, document}, crawl_request})

        # crawl further
        urls_on_page = Enum.map(
          extract_links_from_document(document),
          &link_to_url(url, &1)
        )
        Enum.each(
          urls_on_page,
          &GenServer.cast(
            crawler,
            {
              :new_url,
              CrawlRequest.follow(&1, crawl_request),
            }
          )
        )
      # any error
      {:error, error} -> error
    end
  end
end
