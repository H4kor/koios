defmodule Koios.FoundItemSet do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> MapSet.new() end)
  end

  def has?(set, url) do
    Agent.get(set, &MapSet.member?(&1, url))
  end

  def put(set, url) do
    Agent.update(set, &MapSet.put(&1, url))
  end

  def size(set) do
    Agent.get(set, &MapSet.size(&1))
  end
end
