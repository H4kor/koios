defmodule Asteria.JsonLd do

  defp decode_json(json) do
    case Jason.decode(json) do
      {:error, _} -> nil
      {:ok, value} -> value
    end
  end

  @spec extract(Floki.html_tree()) :: any
  def extract(document) do
    Floki.find(document, "script[type=\"application/ld+json\"]")
      |> Enum.map(&(
        elem(&1, 2)
        |> Enum.at(0)
        |> decode_json
      ))
      |> Enum.filter(& !is_nil(&1))
  end
end
