defmodule Asteria.Microdata do

  defp get_href(node) do
    {:ok, href} = Enum.fetch(Floki.attribute(node, "href"), 0)
    href
  end

  defp get_src(node) do
    {:ok, src} = Enum.fetch(Floki.attribute(node, "src"), 0)
    src
  end

  def process_itemprop(e) do
    attrs = elem(e, 1)
    prop = Enum.filter(attrs, fn attr -> elem(attr, 0) == "itemprop" end)
      |> Enum.at(0, {"itemprop", nil})
      |> elem(1)
    value = case elem(e, 0) do
      # https://stackoverflow.com/a/20283706/1224467
      "a" -> get_href(e)
      "area" -> get_href(e)
      "link" -> get_href(e)
      "img" -> get_src(e)
      _ ->
        case Floki.attribute(e, "itemscope") do
          ["itemscope"] -> process_itemscope(e)
          _ -> String.trim(Floki.raw_html(Floki.children(e)))
        end
    end
    %{prop => value}
  end

  def process_itemprops(e) do
    Floki.find(Floki.children(e), "*[itemprop]")
      |> Enum.map(&process_itemprop(&1))
      |> Enum.reduce(%{}, fn acc, itemprop ->
        Map.merge(acc, itemprop)
      end)
  end

  def process_itemscope(e) do
    attrs = elem(e, 1)
    type = Enum.filter(attrs, fn attr -> elem(attr, 0) == "itemtype" end)
      |> Enum.at(0, {"itemtype", nil})
      |> elem(1)
    unless is_nil(type) do
      context = type |> String.split("/") |> Enum.slice(0..-2) |> Enum.join("/")
      {:ok, type} = type |> String.split("/") |> Enum.fetch(-1)

      empty = %{}
      case process_itemprops(e) do
        ^empty ->
          %{
            "@context" => context,
            "@type" => type,
            "value" => String.trim(Floki.raw_html(Floki.children(e)))
          }
        props ->
          Map.merge(
            %{
              "@context" => context,
              "@type" => type,
            },
            props
          )
      end
    else
      nil
    end
  end

  defp find_main_itempscopes([]) do
    []
  end

  defp find_main_itempscopes([head]) do
    find_main_itempscopes(head)
  end

  defp find_main_itempscopes([head | tail]) do
    case head do
      nil -> find_main_itempscopes(tail)
      _ -> find_main_itempscopes(head) ++ find_main_itempscopes(tail)
    end
  end

  defp find_main_itempscopes(node) when is_tuple(node) do
    case Floki.attribute(node, "itemscope") do
      ["itemscope"] -> [node]
      _ -> case Floki.children(node, include_text: false) do
        nil -> []
        children -> find_main_itempscopes(children)
      end
    end
  end

  def extract(document) do
    find_main_itempscopes(document)
      |> Enum.map(&(
        process_itemscope(&1)
      ))
      |> Enum.filter(& !is_nil(&1))
  end
end
