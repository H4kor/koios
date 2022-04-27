defmodule Koios.Scraper.JSON_LD_Scraper do
  @behaviour Koios.Scraper

  @spec scrape({String.t, Floki.html_tree()}, Koios.CrawlRequest.t) :: any
  def scrape({_, document}, _crawl_request) do
    Asteria.JsonLd.extract(document)
  end

end
