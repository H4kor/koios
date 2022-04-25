defmodule FinderTest do
  use ExUnit.Case, async: false
  doctest Koios.Finder

  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!

  test "start_link send message with domain" do
    Koios.MockHttpClient
    |> expect(:get_page, fn _url ->
        {:ok, "<html><body><a href=\"foo.html\">Hello</a>, world!</body></html>"}
      end)

    Koios.Finder.start_link({"http://www.example.com", 0, self()})
    assert_receive {:found, "www.example.com", %{depth: 0, source: nil}}
    assert_receive {:done}
  end

  test "start_link with depth" do
    Koios.MockHttpClient
    |> expect(:get_page, fn "http://www.example.com" ->
        {:ok, "<html><body><a href=\"foo.html\">Hello</a>, world!</body></html>"}
      end)
    |> expect(:get_page, fn "http://www.example.com/foo.html" ->
        {:ok, "<html><body><a href=\"https://foobar.com\">Hello</a>, world!</body></html>"}
      end)
    |> expect(:get_page, fn "https://foobar.com" ->
        {:ok, "<html><body><a href=\"https://foobar.com\">Hello</a>, world!</body></html>"}
      end)

    Koios.Finder.start_link({"http://www.example.com", 2, self()})
    assert_receive {:found, "www.example.com", %{depth: 0, source:  nil}}
    assert_receive {:found, "foobar.com", %{depth: 2, source: "www.example.com"}}
    assert_receive {:done}
  end

end
