defmodule Koios.DepthConstraint do
  @behaviour Koios.CrawlerConstraint

  @impl true
  @spec valid?(integer, Koios.CrawlRequest.t) :: boolean
  def valid?(max_depth, request) do
    request.depth <= max_depth
  end
end
