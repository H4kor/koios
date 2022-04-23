defmodule Koios.RetrieverRegistryTest do
  use ExUnit.Case, async: true
  doctest Koios.RetrieverRegistry

  # setup do
  #   {:ok, retriever_registry} = Koios.RetrieverRegistry.start_link([])
  #   %{retriever_registry: retriever_registry}
  # end

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

end
