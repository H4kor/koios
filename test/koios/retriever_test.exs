defmodule Koios.RetrieverTest do
  use ExUnit.Case, async: true
  doctest Koios.Retriever

  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  setup do
    {:ok, retriever} = Koios.Retriever.start_link()
    %{retriever: retriever}
  end

  test "valid retriever", %{retriever: retriever} do
    assert retriever
  end

  test "get page", %{retriever: retriever} do
    Koios.MockHttpClient
    |> expect(:get_page, fn _url -> {:ok, "Hello, world!"} end)
    url = "http://www.example.com"
    result = Koios.Retriever.get_page(retriever, url)
    assert result == {:ok, "Hello, world!"}
  end

end
