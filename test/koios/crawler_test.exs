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

    Koios.Crawler.start_link({"http://www.example.com", 0, 1, self()})
    assert_receive {
      :found,
      {_, _},
      %{depth: 0, url: "http://www.example.com"}
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

    Koios.Crawler.start_link({"http://www.example.com", 1, 1, self()})
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

    Koios.Crawler.start_link({"http://www.example.com", 1, 1, self()})
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


  # test "start_link with depth" do
  #   Koios.MockHttpClient
  #   |> expect(:get_page, fn "http://www.example.com" ->
  #       {:ok, "<html><body><a href=\"foo.html\">Hello</a>, world!</body></html>"}
  #     end)
  #   |> expect(:get_page, fn "http://www.example.com/foo.html" ->
  #       {:ok, "<html><body><a href=\"https://foobar.com\">Hello</a>, world!</body></html>"}
  #     end)

  #   Koios.Crawler.start_link({"http://www.example.com", 1, self()})
  #   assert_receive {:found, "www.example.com", %{depth: 0, source: "http://www.example.com", source_domain: "www.example.com"}}
  #   assert_receive {:found, "foobar.com", %{depth: 1, source: "http://www.example.com/foo.html", source_domain: "www.example.com"}}
  # end

end
