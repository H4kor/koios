defmodule Koios do
  use Application

  @impl true
  def start(_type, _args) do
    Koios.Supervisor.start_link(name: Koios.Supervisor)
  end

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
