defmodule Koios.Scraper do
  @callback scrape(pid, {String.t, Floki.html_tree()}, Koios.CrawlRequest.t) :: any
end
