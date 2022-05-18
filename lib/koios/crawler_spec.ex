defmodule Koios.CrawlerSpec do
  defstruct [:url, max_depth: 0, max_tasks: 0, caller: nil]
  @type t() :: %__MODULE__{
    url: String.t(),
    max_depth: integer(),
    max_tasks: integer(),
    caller: pid() | nil,
  }
end
