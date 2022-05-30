defmodule Koios.CrawlerSupervisorTest do
  use ExUnit.Case, async: false
  doctest Koios.CrawlerSupervisor

  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!

  setup do
    {:ok, supervisor} = DynamicSupervisor.start_link([strategy: :one_for_one])

    %{supervisor: supervisor}
  end

  test "crawlers empty", %{supervisor: supervisor} do
    assert Koios.CrawlerSupervisor.crawlers(supervisor) == []
  end

  test "crawlers with one crawler", %{supervisor: supervisor} do
    Koios.MockHttpClient
    |> expect(:get_page, fn _url -> {:ok, "Hello, world!"} end)

    assert Koios.CrawlerSupervisor.crawlers(supervisor) == []
    {:ok, crawler} = DynamicSupervisor.start_child(
      supervisor,
      Koios.Crawler.child_spec(%Koios.CrawlerSpec{
        url: "http://www.example.com", max_tasks: 1, caller: self()
      })
    )
    assert_receive {:found, _, _ }
    assert Koios.CrawlerSupervisor.crawlers(supervisor) == [crawler]
    assert_receive {:done}
    Process.sleep(100)
    assert Koios.CrawlerSupervisor.crawlers(supervisor) == []
  end

  test "crawlers with two terminated crawler", %{supervisor: supervisor} do
    Koios.MockHttpClient
    |> expect(:get_page, fn _url -> {:ok, "Hello, world!"} end)
    |> expect(:get_page, fn _url -> {:ok, "Hello, world!"} end)

    {:ok, crawler_a} = DynamicSupervisor.start_child(
      supervisor,
      Koios.Crawler.child_spec(%Koios.CrawlerSpec{
        url: "http://www.example.com", max_tasks: 1, caller: self()
      })
    )
    {:ok, crawler_b} = DynamicSupervisor.start_child(
      supervisor,
      Koios.Crawler.child_spec(%Koios.CrawlerSpec{
        url: "http://www.example2.com", max_tasks: 1, caller: self()
      })
    )
    assert Koios.CrawlerSupervisor.crawlers(supervisor) == [crawler_a, crawler_b]
    assert_receive {:done}
    assert_receive {:done}
    Process.sleep(100)
    assert Koios.CrawlerSupervisor.crawlers(supervisor) == []
  end

end
