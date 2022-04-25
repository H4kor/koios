defmodule Koios.DepthConstraint do
  @enforce_keys [:max_depth]
  defstruct [:max_depth]
  @type t() :: %__MODULE__{
    max_depth: integer(),
  }

  @behaviour Koios.CrawlerConstraint

  @impl true
  @spec valid?(Koios.DepthConstraint.t, Koios.CrawlRequest.t) :: boolean
  def valid?(config, request) do
    request.depth < config.max_depth
  end
end
