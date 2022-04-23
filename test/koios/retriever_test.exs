defmodule Koios.RetrieverTest do
  use ExUnit.Case, async: true
  doctest Koios.Retriever

  import Mox
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
    result = Koios.Retriever.get_page(retriever, "http://www.example.com")
    assert result == {:ok, "Hello, world!"}
  end

  test "get_page multiple requests wait between calls", %{retriever: retriever} do
    Application.put_env(:koios, :retriever_timeout_ms, 200)
    Koios.MockHttpClient
    |> expect(:get_page, fn _url -> {:ok, "Hello, world!"} end)
    |> expect(:get_page, fn _url -> {:ok, "Hello, world!"} end)

    start = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    Koios.Retriever.get_page(retriever, "http://www.example.com")
    Koios.Retriever.get_page(retriever, "http://www.example2.com")

    stop = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
    diff = stop - start
    assert diff > 200
    Application.put_env(:koios, :retriever_timeout_ms, 0)
  end

end
