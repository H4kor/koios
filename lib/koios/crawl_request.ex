defmodule Koios.CrawlRequest do
  @enforce_keys [:url]
  defstruct [:url, depth: 0, source: nil]
  @type t() :: %__MODULE__{
    url: String.t(),
    depth: integer(),
    source: String.t() | nil,
  }
end
