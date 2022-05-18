defmodule Koios.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Koios.RetrieverRegistry, name: Koios.RetrieverRegistry},
      {DynamicSupervisor, name: Koios.RetrieverSupervisor, strategy: :one_for_one},
      {Koios.Coordinator, name: Koios.Coordinator},
      Koios.CrawlerSupervisor,
      {Task.Supervisor, name: Koios.ScraperTaskSupervisor},
    ]

    # {:ok, scraper} = DynamicSupervisor.start_child(
    #   Koios.ScraperSupervisor,
    #   Koios.Scraper.SchemaScraper.child_spec(:ok)
    # )
    # Koios.Coordinator.add_scraper(Koios.Coordinator, Koios.Scraper.SchemaScraper, scraper)

    # DynamicSupervisor.start_child(
    #   Koios.CrawlerSupervisor,
    #   Koios.Crawler.child_spec({"https://blog.libove.org/", 5, 1000, Koios.Coordinator})
    # )



    Supervisor.init(children, strategy: :one_for_all)
  end
end
