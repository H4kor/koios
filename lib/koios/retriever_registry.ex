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
    domains = %{}
    refs = %{}
    {:ok, {domains, refs}}
  end

  def get_retriever(url) do
    GenServer.call(__MODULE__, {:get_retriever, url})
  end

  @impl true
  def handle_call({:get_retriever, url}, _from, {domains, refs}) do
    uri = URI.parse(url)
    domain = uri.host
    if domain == nil do
      {:noreply, {domains, refs}}
    end
    if Map.has_key?(domains, domain) do
      {:reply, Map.get(domains, domain), {domains, refs}}
    else
      {:ok, new_retriever} = DynamicSupervisor.start_child(
        Koios.RetrieverSupervisor, Koios.Retriever
      )
      ref = Process.monitor(new_retriever)
      refs = Map.put(refs, ref, domain)
      domains = Map.put(domains, domain, new_retriever)
      {:reply, new_retriever, {domains, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {domains, refs}) do
    {domain, refs} = Map.pop(refs, ref)
    domains = Map.delete(domains, domain)
    {:noreply, {domains, refs}}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in KV.Registry: #{inspect(msg)}")
    {:noreply, state}
  end
end
