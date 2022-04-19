defmodule Finder do
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

  def find_on_page(url) do
    page = HTTPClient.get_page(url)
    case page do
      {:ok, html} ->
        case Floki.parse_document(html) do
          {:ok, document} ->
            {:ok, Enum.map(
              extract_links_from_document(document),
              &(a_element_to_link(&1) |> link_to_urls(url))
            )}
          {:error, error} ->
            {:error, {:unable_to_parse_document, error}}
        end
      {:error, error} ->
        {:error, {:unable_to_get_page, error}}
    end
  end

end
