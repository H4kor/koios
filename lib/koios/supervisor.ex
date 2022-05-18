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
    Supervisor.init(children, strategy: :one_for_all)
  end
end
