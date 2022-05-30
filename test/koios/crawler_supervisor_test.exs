defmodule Koios.CrawlerSupervisorTest do
  use ExUnit.Case, async: false
  doctest Koios.CrawlerSupervisor

  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!

  test "crawlers empty" do
    assert Koios.CrawlerSupervisor.crawlers() == []
  end

  test "crawlers with one crawler" do
    Koios.MockHttpClient
    |> expect(:get_page, fn _url -> {:ok, "Hello, world!"} end)

    assert Koios.CrawlerSupervisor.crawlers() == []
    {:ok, crawler} = Koios.start_crawler(%Koios.CrawlerSpec{
      url: "http://www.example.com", max_tasks: 1, caller: self()
    })
    assert_receive {:found, _, _ }
    assert Koios.CrawlerSupervisor.crawlers() == [crawler]
    assert_receive {:done}
    assert Koios.CrawlerSupervisor.crawlers() == []
  end

  test "crawlers with two terminated crawler" do
    Koios.MockHttpClient
    |> expect(:get_page, fn _url -> {:ok, "Hello, world!"} end)
    |> expect(:get_page, fn _url -> {:ok, "Hello, world!"} end)

    {:ok, crawler_a} = Koios.start_crawler(%Koios.CrawlerSpec{
      url: "http://www.example.com", max_tasks: 1, caller: self()
    })
    {:ok, crawler_b} = Koios.start_crawler(%Koios.CrawlerSpec{
      url: "http://www.example2.com", max_tasks: 1, caller: self()
    })
    assert Koios.CrawlerSupervisor.crawlers() == [crawler_a, crawler_b]
    assert_receive {:done}
    assert_receive {:done}
    assert Koios.CrawlerSupervisor.crawlers() == []
  end

end
