defmodule Koios.Scraper.JSON_LD_Scraper do
  @behaviour Koios.Scraper

  @spec scrape({String.t, Floki.html_tree()}, Koios.CrawlRequest.t) :: any
  def scrape({_, document}, _crawl_request) do
    Floki.find(document, "script[type=\"application/ld+json\"]")
      |> Enum.map(&(
        elem(&1, 2)
        |> Enum.at(0)
        |> Jason.decode!
      ))
  end

end
