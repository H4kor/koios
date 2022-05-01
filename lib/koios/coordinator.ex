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
  def handle_cast({:add_scraper, scraper, pid}, state = %{scrapers: scrapers}) do
    {:noreply, %{
      state
      | scrapers: (scrapers ++ [{scraper, pid}])
    }}
  end

  @impl true
  def handle_call({:get_scrapers}, _from, state = %{scrapers: scrapers}) do
    {:reply, scrapers, state}
  end

  @impl true
  def handle_info({:found, body, req}, state = %{scrapers: scrapers}) do
    Enum.each(scrapers, fn {scraper, pid} -> scraper.scrape(pid, body, req) end)
    {:noreply, state}
  end

  def add_scraper(coordinator, scraper, pid) do
    GenServer.cast(coordinator, {:add_scraper, scraper, pid})
  end

  def get_scrapers(coordinator) do
    GenServer.call(coordinator, {:get_scrapers})
  end
end
