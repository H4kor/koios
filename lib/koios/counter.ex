defmodule Koios.Counter do
  use Agent

  def start_link() do
    Agent.start_link(fn -> 0 end)
  end

  def value(counter) do
    Agent.get(counter, & &1)
  end

  def increment(counter) do
    Agent.update(counter, &(&1 + 1))
  end
end
