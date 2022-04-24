defmodule Koios.Finder do
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

  defp handle_result(result_url, context = %{
    depth: depth,
    max_depth: max_depth,
    caller: caller,
    found_pages: found_pages,
    found_domains: found_domains,
    source: source,
  }) do
    unless Koios.FoundItemSet.has?(found_pages, result_url) do
      domain = get_domain(result_url)
      unless Koios.FoundItemSet.has?(found_domains, domain) || domain == nil do
        send(caller, {:found, domain, %{source: source, source_domain: get_domain(source), depth: depth}})
        Koios.FoundItemSet.put(found_domains, domain)
      end
      Koios.FoundItemSet.put(found_pages, result_url)
      if depth < max_depth do
        spawn(
          fn -> scrape_page(result_url, %{context | depth: depth+1} ) end
        )
      end
    end
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

  defp scrape_page(url, context) do
    # IO.puts("Depth #{depth}/#{max_depth} Scraping #{url}. (Found #{Koios.FoundItemSet.size(found_pages)})")
    case download_page_as_html(url) do
      {:ok, document} ->
        urls_on_page = Enum.map(
          extract_links_from_document(document),
          &link_to_url(&1, url)
        )
        Enum.each(urls_on_page, &(handle_result(&1, %{context | source: url})))
      # any error
      {:error, error} -> error
    end
  end

  def find_on_page(url, max_depth, caller) do
    {:ok, found_pages} = Koios.FoundItemSet.start_link([])
    {:ok, found_domains} = Koios.FoundItemSet.start_link([])
    Task.start_link(fn -> scrape_page(url, %{
      depth: 0,
      max_depth: max_depth,
      caller: caller,
      found_pages: found_pages,
      found_domains: found_domains,
      source: url
    }) end)
  end

  def find_on_page(url, caller) do
    find_on_page(url, 0, caller)
  end

end
