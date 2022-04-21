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
    Floki.find(document, "a")
  end

  defp link_to_urls(link, base_url) do
    URI.merge(URI.parse(base_url), link) |> to_string()
  end

  defp handle_result(result, depth, max_depth, caller, found_pages) do
    unless Koios.FoundPages.has(found_pages, result) do
      send(caller, {:found, result})
      Koios.FoundPages.put(found_pages, result)
      if depth < max_depth do
        spawn(
          fn -> scrape_page(result, depth, max_depth, caller, found_pages) end
        )
      end
    end
  end

  defp scrape_page(url, depth, max_depth, caller, found_pages) do
    resp = Koios.RetrieverRegistry.get_retriever(url)
      |> Koios.Retriever.get_page(url)
    case resp do
      # got content
      {:ok, content} ->
        parser_result = Floki.parse_document(content)
        case parser_result do
          # successfully parsed
          {:ok, document} ->
            links_on_page = Enum.map(
              extract_links_from_document(document),
              &(a_element_to_link(&1) |> link_to_urls(url))
            )
            Enum.each(links_on_page, &(handle_result(&1, depth, max_depth, caller, found_pages)))
          # any error
          _ -> nil
        end
      # any error
      _ -> nil
    end
  end

  def find_on_page(url, max_depth, caller) do
    found_pages = Koios.FoundPages.start_link([])
    scrape_page(url, 0, max_depth, caller, found_pages)
  end

  def find_on_page(url, caller) do
    find_on_page(url, 0, caller)
  end

end
