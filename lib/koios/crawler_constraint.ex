defmodule Koios.CrawlerConstraint do
  @callback valid?(any, CrawlRequest.t) :: boolean
end
