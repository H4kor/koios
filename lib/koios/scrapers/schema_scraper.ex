defmodule Koios.Scraper.SchemaScraper do
  @behaviour Koios.Scraper

  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok)
  end

  def start_link(:ok) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def handle_cast({:scrape, doc, req}, state) do
    schemas = Asteria.JsonLd.extract(doc) ++ Asteria.Microdata.extract(doc)
    IO.puts("#{Enum.count(schemas)} schemas found on #{req.url}")
    {:noreply, state}
  end

  @impl true
  def scrape(scraper, {_, document}, req) do
    GenServer.cast(scraper, {:scrape, document, req})
  end

end
