defmodule Koios.Crawler do
  use GenServer
  alias Koios.CrawlRequest
  alias Koios.Queue
  alias Koios.Set

  import Koios.Util.UrlUtil

  @spec start_link(Koios.CrawlerSpec.t()) :: {:ok, pid}
  def start_link(config, opts\\[]) do
    GenServer.start_link(__MODULE__, config, opts)
  end

  @impl true
  def init(config) do
    {:ok, visited_pages} = Set.start_link([])
    {:ok, open_tasks} = Set.start_link([])
    {:ok, open_urls} = Queue.start_link([])

    Queue.push(open_urls, %CrawlRequest{url: config.url})

    schedule_work()

    {:ok, %{
      max_tasks: config.max_tasks,
      max_depth: config.max_depth,
      caller: config.caller,
      visited_pages: visited_pages,
      open_tasks: open_tasks,
      open_urls: open_urls,
      crawler: self(),
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
    if Set.size(open_tasks) < max_tasks do
      case Queue.pop(open_urls) do
        req when is_struct(req, CrawlRequest) ->
          new_task = Task.async(
            fn -> crawl_page(req, context) end
          )
          Set.put(open_tasks, new_task.ref)
          schedule_work()
          {:noreply, context}
        nil ->
          if Set.size(open_tasks) == 0 do
            # no more urls, no more tasks -> we are done
            send(caller, {:done})
            {:noreply, context, :hibernate}
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
  def handle_info({:DOWN, ref, _, _, _reason}, context = %{open_tasks: open_tasks}) do
    Set.remove(open_tasks, ref)
    schedule_work()
    {:noreply, context}
  end

  @impl true
  def handle_cast(
    {:new_url, %CrawlRequest{url: url, depth: depth, source: source}},
    context = %{
      max_depth: max_depth,
      visited_pages: visited_pages,
      open_urls: open_urls,
    }
  ) do
    unless url == nil or Set.has?(visited_pages, url) do
      if depth <= max_depth do
        Set.put(visited_pages, url)
        Queue.push(open_urls, %CrawlRequest{url: url, depth: depth, source: source})
        schedule_work()
      end
    end
    {:noreply, context}
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
