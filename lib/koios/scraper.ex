defmodule Koios.Scraper do

  @callback scrape({String.t, Floki.html_tree()}, Koios.CrawlRequest.t) :: any

end
