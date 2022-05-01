defmodule Koios.MockScraper do
  use GenServer
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def start_link(caller) do
    GenServer.start_link(__MODULE__, {caller}, [])
  end

  @impl true
  def init(:ok) do
    {:ok, %{
      caller: nil
    }}
  end

  @impl true
  def init({caller}) do
    {:ok, %{
      caller: caller
    }}
  end

  @impl true
  def handle_cast({:scrape, body, crawl_request}, state = %{caller: caller}) do
    if caller != nil do
      send(caller, {:got, body, crawl_request})
    end
    {:noreply, state}
  end

  def scrape(scraper, data, req) do
    GenServer.cast(scraper, {:scrape, data, req})
  end
end


defmodule Koios.CoordinatorTest do
  use ExUnit.Case, async: true
  doctest Koios.Coordinator

  setup do
    {:ok, coordinator} = Koios.Coordinator.start_link()
    {:ok, scraper} = Koios.MockScraper.start_link(self())

    %{coordinator: coordinator, scraper: scraper}
  end

  test "add scraper with empty coordinator", %{coordinator: coordinator, scraper: scraper} do
    Koios.Coordinator.add_scraper(coordinator, Koios.MockScraper, scraper)
    assert Koios.Coordinator.get_scrapers(coordinator) == [{Koios.MockScraper, scraper}]
  end

  test "data send to scraper", %{coordinator: coordinator, scraper: scraper} do
    Koios.Coordinator.add_scraper(coordinator, Koios.MockScraper, scraper)
    send coordinator, {
      :found,
      {"hello", "hello"},
      %Koios.CrawlRequest{url: "http://example.com"}
    }
    assert_receive {
      :got,
      {"hello", "hello"},
      %Koios.CrawlRequest{url: "http://example.com"}
    }
  end

  test "multiple scrapers", %{coordinator: coordinator} do
    {:ok, scraper} = Koios.MockScraper.start_link(self())
    Koios.Coordinator.add_scraper(coordinator, Koios.MockScraper, scraper)
    {:ok, scraper} = Koios.MockScraper.start_link(self())
    Koios.Coordinator.add_scraper(coordinator, Koios.MockScraper, scraper)
    {:ok, scraper} = Koios.MockScraper.start_link(self())
    Koios.Coordinator.add_scraper(coordinator, Koios.MockScraper, scraper)
    send coordinator, {
      :found,
      {"hello", "hello"},
      %Koios.CrawlRequest{url: "http://example.com"}
    }
    assert_receive {
      :got,
      {"hello", "hello"},
      %Koios.CrawlRequest{url: "http://example.com"}
    }
    assert_receive {
      :got,
      {"hello", "hello"},
      %Koios.CrawlRequest{url: "http://example.com"}
    }
    assert_receive {
      :got,
      {"hello", "hello"},
      %Koios.CrawlRequest{url: "http://example.com"}
    }
  end

end
