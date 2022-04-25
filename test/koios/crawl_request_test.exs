defmodule Koios.CrawlRequestTest do
  use ExUnit.Case, async: false
  doctest Koios.CrawlRequest

  test "default depth" do
    assert(0 == %Koios.CrawlRequest{url: "http://www.example.com"}.depth)
  end

  test "default source" do
    assert(nil == %Koios.CrawlRequest{url: "http://www.example.com"}.source)
  end

end
