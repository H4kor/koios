defmodule Asteria.Microdata do

  def process_itemprop(e) do
    attrs = elem(e, 1)
    prop = Enum.filter(attrs, fn attr -> elem(attr, 0) == "itemprop" end)
      |> Enum.at(0, {"itemprop", nil})
      |> elem(1)
    {:ok, value} = Enum.fetch(elem(e, 2), 0)
    %{prop => value}
  end

  def process_itemprops(e) do
    Floki.find(e, "*[itemprop]")
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
      Map.merge(
        %{
          "@context" => context,
          "@type" => type,
        },
        process_itemprops(e)
      )
    else
      nil
    end
  end

  def extract(document) do
    Floki.find(document, "*[itemscope]")
      |> Enum.map(&(
        process_itemscope(&1)
      ))
      # |> Enum.filter(& !is_nil(&1))
  end
end
