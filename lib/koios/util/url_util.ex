defmodule Koios.Util.UrlUtil do

  @spec a_element_to_link(tuple) :: String.t | nil
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

  @doc ~S"""
    Extracts all links from a document.
  """
  @spec extract_links_from_document(
    binary() | Floki.html_tree() | Floki.html_node()
  ) :: [String.t]
  def extract_links_from_document(document) do
    Enum.filter(
      Enum.map(Floki.find(document, "a"), &a_element_to_link(&1)),
      fn link -> link != nil end
    )
  end

  @doc ~S"""
    Combine links with base url.

    ## Examples

      iex> Koios.Util.UrlUtil.link_to_url("http://example.com/", "foo.html")
      "http://example.com/foo.html"

      iex> Koios.Util.UrlUtil.link_to_url("http://example.com/bar/", "/foo.html")
      "http://example.com/foo.html"

      iex> Koios.Util.UrlUtil.link_to_url("http://example.com/bar/baz/", "http://foobar.com")
      "http://foobar.com"

      iex> Koios.Util.UrlUtil.link_to_url("http://example.com/bar/", "")
      "http://example.com/bar/"

      iex> Koios.Util.UrlUtil.link_to_url("http://example.com/bar/", nil)
      nil
  """
  @spec link_to_url(String.t, String.t) :: String.t | nil
  def link_to_url(base_url, link) do
    try do
      URI.merge(URI.parse(base_url), link) |> to_string()
    rescue
      _ -> nil
    end
  end

end
