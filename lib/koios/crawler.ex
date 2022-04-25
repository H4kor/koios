defmodule Koios.Crawler do
  use GenServer

  def start_link(config, opts\\[]) do
    GenServer.start_link(__MODULE__, config, opts)
  end

  @impl true
  def init({start_url, max_depth, max_tasks, caller}) do
    {:ok, visited_pages} = Koios.Set.start_link([])
    {:ok, open_tasks} = Koios.Set.start_link([])
    {:ok, open_urls} = Koios.Queue.start_link([])

    Koios.Queue.push(open_urls, %{url: start_url, depth: 0, source: nil})

    schedule_work()

    {:ok, %{
      max_tasks: max_tasks,
      max_depth: max_depth,
      caller: caller,
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
    if Koios.Set.size(open_tasks) < max_tasks do
      case Koios.Queue.pop(open_urls) do
        %{url: url, depth: depth, source: source} ->
          new_task = Task.async(
            fn -> crawl_page(url, depth, source, context) end
          )
          Koios.Set.put(open_tasks, new_task.ref)
          schedule_work()
          {:noreply, context}
        nil ->
          if Koios.Set.size(open_tasks) == 0 do
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
    Koios.Set.remove(open_tasks, ref)
    schedule_work()
    {:noreply, context}
  end

  @impl true
  def handle_cast({:new_url, result_url, depth, source}, context = %{
    max_depth: max_depth,
    visited_pages: visited_pages,
    open_urls: open_urls,
  }) do
    unless result_url == nil or Koios.Set.has?(visited_pages, result_url) do
      if depth < max_depth do
        Koios.Set.put(visited_pages, result_url)
        Koios.Queue.push(open_urls, %{url: result_url, depth: depth + 1, source: source})
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

  defp crawl_page(url, depth, source, %{caller: caller, crawler: crawler}) do
    case download_page(url) do
      {:ok, {raw, document}} ->
        # send data to caller
        send(caller, {:found, {raw, document}, %{url: url, depth: depth, source: source}})

        # crawl further
        urls_on_page = Enum.map(
          extract_links_from_document(document),
          &link_to_url(&1, url)
        )
        Enum.each(
          urls_on_page,
          &GenServer.cast(crawler, {:new_url, &1, depth, url})
        )
      # any error
      {:error, error} -> error
    end
  end

  defp a_element_to_link(a_element) do
    if Kernel.tuple_size(a_element) < 2 do
      nil
    else
      hrefs = Enum.filter(
        elem(a_element,1),
        fn attr -> elem(attr, 0) == "href" end
      )
      if Enum.count(hrefs) < 1 do
        nil
      else
        elem(Enum.at(hrefs, 0, {"href", nil}), 1)
      end
    end
  end

  defp extract_links_from_document(document) do
    Enum.filter(
      Enum.map(Floki.find(document, "a"), &a_element_to_link(&1)),
      fn link -> link != nil end
    )
  end

  defp link_to_url(link, base_url) do
    try do
      URI.merge(URI.parse(base_url), link) |> to_string()
    rescue
      _ ->
        IO.puts("Failed to join on #{base_url} and #{link}")
        nil
    end
  end

end
