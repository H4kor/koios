defmodule Koios.CrawlerSpec do
  defstruct [:url, max_tasks: 1, caller: nil, constraints: []]
  @type t() :: %__MODULE__{
    url: String.t(),
    max_tasks: integer(),
    caller: pid() | nil,
    constraints: [Koios.Constraint.t()],
  }
end
