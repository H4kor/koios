defmodule Koios.RetrieverRegistryTest do
  use ExUnit.Case, async: true
  doctest Koios.RetrieverRegistry

  test "get retriever returns same retriever for two domains" do
    result_1 = Koios.RetrieverRegistry.get_retriever("http://www.example.com")
    result_2 = Koios.RetrieverRegistry.get_retriever("http://www.example.com/foo")
    assert result_1 == result_2
  end

  test "get retriever returns different retriever for two domains" do
    result_1 = Koios.RetrieverRegistry.get_retriever("http://www.example.com")
    result_2 = Koios.RetrieverRegistry.get_retriever("http://www.foobar.com")
    assert result_1 != result_2
  end

  test "removes registries on exit" do
    first_retriever = Koios.RetrieverRegistry.get_retriever("http://www.example.com")
    GenServer.stop(first_retriever)
    second_retriever = Koios.RetrieverRegistry.get_retriever("http://www.example.com")
    assert first_retriever != second_retriever
  end


end
