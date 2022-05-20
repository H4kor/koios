defmodule Koios do
  @moduledoc """
  Documentation for `Koios`.
  """

  def add_scraper(scraper, config) do
    Koios.Coordinator.add_scraper(Koios.Coordinator, scraper, config)
  end

  def start_crawler(config) do
    config = case config.caller do
      nil -> %Koios.CrawlerSpec{config | caller: Koios.Coordinator}
      _ -> config
    end
    DynamicSupervisor.start_child(
      Koios.CrawlerSupervisor,
      Koios.Crawler.child_spec(config)
    )
  end
end
