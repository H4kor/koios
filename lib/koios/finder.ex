defmodule Koios.Finder do
  use GenServer
  @moduledoc """
  Finds websites in the web. Only concerns itself with the domain name.
  """

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

  defp get_domain(url) do
    URI.parse(url).host
  end

  @impl true
  def handle_cast({:new_url, result_url, depth, source}, context = %{
    max_depth: max_depth,
    caller: caller,
    found_pages: found_pages,
    found_domains: found_domains,
    open_urls: open_urls,
  }) do
    unless result_url == nil or Koios.Set.has?(found_pages, result_url) do
      domain = get_domain(result_url)
      unless Koios.Set.has?(found_domains, domain) || domain == nil do
        send(caller, {:found, domain, %{source: source, source_domain: get_domain(source), depth: depth}})
        Koios.Set.put(found_domains, domain)
      end
      Koios.Set.put(found_pages, result_url)
      if depth < max_depth do
        Koios.Queue.push(open_urls, %{url: result_url, depth: depth + 1})
        schedule()
        # scrape_page(result_url, %{context | depth: depth+1} )
      end
    end
    {:noreply, context}
  end

  defp download_page_as_html(url) do
    resp = Koios.RetrieverRegistry.get_retriever(url)
      |> Koios.Retriever.get_page(url)
    case resp do
      # got content
      {:ok, content} ->
        parser_result = Floki.parse_document(content)
        case parser_result do
          # successfully parsed
          {:ok, document} -> {:ok, document}
          # failed to parse
          {:error, err} -> {:error, err}
        end
      {:error, err} -> {:error, err}
    end
  end

  defp scrape_page(url, depth, context = %{finder: finder}) do
    # IO.puts("Depth #{depth}/#{max_depth} Scraping #{url}. (Found #{Koios.Set.size(found_pages)})")
    case download_page_as_html(url) do
      {:ok, document} ->
        urls_on_page = Enum.map(
          extract_links_from_document(document),
          &link_to_url(&1, url)
        )
        Enum.each(
          urls_on_page,
          &GenServer.cast(finder, {:new_url, &1, depth, url})
          # &handle_result(&1, depth, %{context | source: url})
        )
      # any error
      {:error, error} -> error
    end
  end

  @impl true
  def handle_info(:schedule, context = %{open_tasks: open_tasks, open_urls: open_urls}) do
    # create new tasks from open_urls
    if Koios.Set.size(open_tasks) < 1000 do
      case Koios.Queue.pop(open_urls) do
        %{url: url, depth: depth} ->
          new_task = Task.async(
            fn -> scrape_page(url, depth, context) end
          )
          Koios.Set.put(open_tasks, new_task.ref)
          schedule()
        nil -> nil
      end
    end
    IO.puts("Open tasks: #{Koios.Set.size(open_tasks)}, Open Urls: #{Koios.Queue.size(open_urls)}")
    {:noreply, context}
  end

  @impl true
  def handle_info({ref, result}, context = %{open_tasks: open_tasks}) do
    # IO.puts("Task #{inspect ref} finished with result #{inspect result}")
    Koios.Set.remove(open_tasks, ref)
    schedule()
    {:noreply, context}
  end

  def handle_info({:DOWN, ref, _, _, reason}, context = %{open_tasks: open_tasks}) do
    # IO.puts("Task #{inspect ref} failed with reason #{inspect reason}")
    Koios.Set.remove(open_tasks, ref)
    schedule()
    {:noreply, context}
  end

  def start_link({url, max_depth, caller}) do
    GenServer.start_link(__MODULE__, {url, max_depth, caller})
  end

  @impl true
  def init({url, max_depth, caller}) do
    {:ok, found_pages} = Koios.Set.start_link([])
    {:ok, found_domains} = Koios.Set.start_link([])
    {:ok, open_tasks} = Koios.Set.start_link([])
    {:ok, open_urls} = Koios.Queue.start_link([])

    Koios.Queue.push(open_urls, %{url: url, depth: 0})

    schedule()

    {:ok, %{
      max_depth: max_depth,
      caller: caller,
      found_pages: found_pages,
      found_domains: found_domains,
      open_tasks: open_tasks,
      open_urls: open_urls,
      source: url,
      finder: self(),
    }}
  end

  defp schedule() do
    send(self(), :schedule)
  end

end
