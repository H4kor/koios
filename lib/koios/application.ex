defmodule Koios.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Koios.RetrieverRegistry, name: Koios.RetrieverRegistry},
      {DynamicSupervisor, name: Koios.RetrieverSupervisor, strategy: :one_for_one},
      {Koios.Coordinator, name: Koios.Coordinator},
      Koios.CrawlerSupervisor,
      {Task.Supervisor, name: Koios.ScraperTaskSupervisor},
    ]

    opts = [strategy: :one_for_one, name: Asteria.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
