defmodule Koios.Queue do
  use GenServer

  def start_link(opts\\[]) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    {:ok, []}
  end

  @impl true
  def handle_call({:pop}, _from, list) do
    {last, remain} = List.pop_at(list, -1)
    {:reply, last, remain}
  end

  @imple true
  def handle_call({:size}, _from, list) do
    {:reply, Enum.count(list), list}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end

  def pop(queue) do
    GenServer.call(queue, {:pop})
  end

  def push(queue, element) do
    GenServer.cast(queue, {:push, element})
  end

  def size(queue) do
    GenServer.call(queue, {:size})
  end


end
