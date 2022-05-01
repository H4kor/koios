defmodule Koios.Scraper do
  @callback start_link() :: {:ok, pid}
  @callback start_link(any) :: {:ok, pid}
  @callback scrape(pid, {String.t, Floki.html_tree()}, Koios.CrawlRequest.t) :: any

end
