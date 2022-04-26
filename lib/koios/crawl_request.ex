defmodule Koios.CrawlRequest do
  @enforce_keys [:url]
  defstruct [:url, depth: 0, source: nil]
  @type t() :: %__MODULE__{
    url: String.t(),
    depth: integer(),
    source: String.t() | nil,
  }

  def follow(url, prev) do
    %Koios.CrawlRequest{url: url, depth: prev.depth + 1, source: prev.url}
  end
end
