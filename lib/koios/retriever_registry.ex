defmodule Koios.RetrieverRegistry do
  @moduledoc """
  The Koios.RetrieverRegistry module provides a registry of Koios.Retriever instances.
  A separate Retriever is provided for each domain.
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  def get_retriever(url) do
    GenServer.call(__MODULE__, {:get_retriever, url})
  end

  @impl true
  def handle_call({:get_retriever, url}, _from, retrievers) do
    uri = URI.parse(url)
    domain = uri.host
    if domain == nil do
      {:noreply, retrievers}
    end
    if Map.has_key?(retrievers, domain) do
      {:reply, Map.get(retrievers, domain), retrievers}
    else
      {:ok, new_retriever} = Koios.Retriever.start_link()
      {:reply, new_retriever, Map.put(retrievers, domain, new_retriever)}
    end
  end
end
