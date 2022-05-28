defmodule Koios.Finder do
  use GenServer
  @moduledoc """
  Finds websites in the web. Only concerns itself with the domain name.
  """


  defp get_domain(url) do
    unless url == nil do
      URI.parse(url).host
    else
      nil
    end
  end

  @impl true
  def handle_info(
    {:found, _content, %{url: url, source: source, depth: depth}},
    context = %{found_domains: found_domains, caller: caller}
  ) do
    unless Koios.Set.has?(found_domains, get_domain(url)) do
      Koios.Set.put(found_domains, get_domain(url))
      send(caller, {:found, get_domain(url), %{source: get_domain(source), depth: depth}})
    end
    {:noreply, context}
  end

  @impl true
  def handle_info({:done}, context = %{caller: caller}) do
    send(caller, {:done})
    {:noreply, context}
    # {:stop, :done, context}
  end

  def start_link({url, max_depth, caller}) do
    GenServer.start_link(__MODULE__, {url, max_depth, caller})
  end

  @impl true
  def init({url, max_depth, caller}) do
    {:ok, found_domains} = Koios.Set.start_link([])
    {:ok, crawler} = Koios.Crawler.start_link(%Koios.CrawlerSpec{
      url: url, max_tasks: 100, caller: self()
    } |> Koios.add_constraint(Koios.DepthConstraint, max_depth))

    {:ok, %{
      caller: caller,
      found_domains: found_domains,
      crawler: crawler,
      finder: self(),
    }}
  end
end
