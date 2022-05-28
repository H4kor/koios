defmodule CrawlerTest do
  use ExUnit.Case, async: false
  doctest Koios.Crawler

  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!

  test "start_link send message with content and html" do
    Koios.MockHttpClient
    |> expect(:get_page, fn _url ->
        {:ok, "<html><body><a href=\"foo.html\">Hello</a>, world!</body></html>"}
      end)

    Koios.Crawler.start_link(%Koios.CrawlerSpec{
      url: "http://www.example.com", max_tasks: 1, caller: self()
    } |> Koios.add_constraint(Koios.DepthConstraint, 0))
    assert_receive {
      :found,
      {_, _},
      %{depth: 0, url: "http://www.example.com", source: nil}
    }
    assert_receive {:done}
  end

  test "start_link send multiple messages with content and html" do
    Koios.MockHttpClient
    |> expect(:get_page, fn "http://www.example.com" ->
        {:ok, "<html><body><a href=\"foo.html\">Hello</a>, world!</body></html>"}
      end)
    |> expect(:get_page, fn "http://www.example.com/foo.html" ->
        {:ok, "<html><body><a href=\"https://foobar.com\">Hello</a>, world!</body></html>"}
      end)

    Koios.Crawler.start_link(%Koios.CrawlerSpec{
      url: "http://www.example.com", max_tasks: 1, caller: self()
    } |> Koios.add_constraint(Koios.DepthConstraint, 1))
    assert_receive {
      :found,
      {_, _},
      %{depth: 0, url: "http://www.example.com", source: nil}
    }
    assert_receive {
      :found,
      {_, _},
      %{depth: 1, url: "http://www.example.com/foo.html", source: "http://www.example.com"}
    }
    assert_receive {:done}
  end

  test "start_link send multiple urls on one page" do
    Koios.MockHttpClient
    |> expect(:get_page, fn "http://www.example.com" ->
        {:ok, "
        <html><body>
        <a href=\"foo.html\">Hello</a>
        <a href=\"bar.html\">Hello</a>
        <a href=\"baz.html\">Hello</a>
        </body></html>"}
      end)
    |> expect(:get_page, fn "http://www.example.com/foo.html" ->
        {:ok, "<html><body>Foo</body></html>"}
      end)
    |> expect(:get_page, fn "http://www.example.com/bar.html" ->
        {:ok, "<html><body>Foo</body></html>"}
      end)
    |> expect(:get_page, fn "http://www.example.com/baz.html" ->
        {:ok, "<html><body>Foo</body></html>"}
      end)

    Koios.Crawler.start_link(%Koios.CrawlerSpec{
      url: "http://www.example.com", max_tasks: 1, caller: self()
    } |> Koios.add_constraint(Koios.DepthConstraint, 1))
    assert_receive {
      :found,
      {_, _},
      %{depth: 0, url: "http://www.example.com"}
    }
    assert_receive {
      :found,
      {_, _},
      %{depth: 1, url: "http://www.example.com/foo.html"}
    }
    assert_receive {
      :found,
      {_, _},
      %{depth: 1, url: "http://www.example.com/bar.html"}
    }
    assert_receive {
      :found,
      {_, _},
      %{depth: 1, url: "http://www.example.com/baz.html"}
    }
    assert_receive {:done}
  end

  test "start_link with connection error" do
    Koios.MockHttpClient
    |> expect(:get_page, fn _url ->
        {:error, :test_error}
      end)

    Koios.Crawler.start_link(%Koios.CrawlerSpec{
      url: "http://www.example.com", max_tasks: 1, caller: self()
    } |> Koios.add_constraint(Koios.DepthConstraint, 0))
    assert_receive {:done}
    refute_received {:found, _, _}
  end

  test "start_link page only crawled once" do
    Koios.MockHttpClient
    |> expect(:get_page, fn "http://www.example.com" ->
        {:ok, "
        <html><body>
        <a href=\"foo.html\">Hello</a>
        <a href=\"bar.html\">Hello</a>
        </body></html>"}
      end)
    |> expect(:get_page, fn "http://www.example.com/foo.html" ->
        {:ok, "<html><body></body></html>"}
      end)
    |> expect(:get_page, fn "http://www.example.com/bar.html" ->
        {:ok, "
        <html><body>
        <a href=\"foo.html\">Hello</a>
        </body></html>"}
      end)

    Koios.Crawler.start_link(%Koios.CrawlerSpec{
      url: "http://www.example.com", max_tasks: 1, caller: self()
    } |> Koios.add_constraint(Koios.DepthConstraint, 50))
    assert_receive {
      :found,
      {_, _},
      %{depth: 0, url: "http://www.example.com", source: nil}
    }
    assert_receive {
      :found,
      {_, _},
      %{depth: 1, url: "http://www.example.com/foo.html", source: "http://www.example.com"}
    }
    assert_receive {
      :found,
      {_, _},
      %{depth: 1, url: "http://www.example.com/bar.html", source: "http://www.example.com"}
    }
    refute_received {
      :found,
      {_, _},
      %{depth: 2, url: "http://www.example.com/foo.html", source: "http://www.example.com/bar.html"}
    }
    assert_receive {:done}
  end

end
