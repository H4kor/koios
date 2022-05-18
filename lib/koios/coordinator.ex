defmodule Koios.Coordinator do
  @doc """
  Crawler results are sent to the coordinator and the coordinator
  forwards the results to the appropriate scrapers.
  """
  use GenServer

  def start_link(opts\\[]) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    {:ok, %{
      scrapers: []
    }}
  end

  @impl true
  def handle_cast({:add_scraper, scraper, config}, state = %{scrapers: scrapers}) do
    {:noreply, %{
      state
      | scrapers: (scrapers ++ [{scraper, config}])
    }}
  end

  @impl true
  def handle_call({:get_scrapers}, _from, state = %{scrapers: scrapers}) do
    {:reply, scrapers, state}
  end

  @impl true
  def handle_info({:found, body, req}, state = %{scrapers: scrapers}) do
    Enum.each(scrapers, fn {scraper, config} -> Task.Supervisor.start_child(
      Koios.ScraperTaskSupervisor,
      fn -> scraper.scrape(config, body, req) end
    ) end )
    {:noreply, state}
  end

  def handle_info({:done}, state) do
    {:noreply, state}
  end

  def add_scraper(coordinator, scraper, config) do
    GenServer.cast(coordinator, {:add_scraper, scraper, config})
  end

  def get_scrapers(coordinator) do
    GenServer.call(coordinator, {:get_scrapers})
  end
end
