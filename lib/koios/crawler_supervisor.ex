defmodule Koios.CrawlerSupervisor do
  # Automatically defines child_spec/1
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def crawlers() do
    DynamicSupervisor.which_children(Koios.CrawlerSupervisor)
    |> Enum.map(&elem(&1, 1))
    |> Enum.filter(&(&1 != :restarting))
  end
end
