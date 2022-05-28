defmodule Koios do
  @moduledoc """
  Documentation for `Koios`.
  """

  @doc ~S"""
  Adds a Scraper to the default Coordinator.
  """
  def add_scraper(scraper, config) do
    Koios.Coordinator.add_scraper(Koios.Coordinator, scraper, config)
  end

  @doc ~S"""
  Creates a new Crawler Specification.

  ## Examples
  ```elixir
  iex> Koios.build_crawler("https://example.com")
  %Koios.CrawlerSpec{:url => "https://example.com"}
  ```
  """
  @spec build_crawler(String.t()) :: Koios.CrawlerSpec.t()
  def build_crawler(url) do
    %Koios.CrawlerSpec{url: url}
  end

  @doc ~S"""
  Adds an additional constraint to a Crawler Specification.

  ## Examples

  ```elixir
  Koios.build_crawler("https://example.com")
  |> add_constraint(Koios.DepthConstraint, 1)
  ```
  """
  @spec add_constraint(Koios.CrawlerSpec.t(), Koios.Constraint.t(), any) :: Koios.CrawlerSpec.t()
  def add_constraint(crawler_spec, constraint, params) do
    %Koios.CrawlerSpec{
      crawler_spec |
      constraints: [{constraint, params} | crawler_spec.constraints],
    }
  end

  @doc ~S"""
  Sets the maximum number of tasks that can be run concurrently by this crawler.

  ## Examples

  ```elixir
  Koios.build_crawler("https://example.com")
  |> set_max_tasks(2)
  ```
  """
  @spec max_tasks(Koios.CrawlerSpec.t(), integer()) :: Koios.CrawlerSpec.t()
  def max_tasks(crawler_spec, max_tasks) do
    %Koios.CrawlerSpec{
      crawler_spec |
      max_tasks: max_tasks,
    }
  end

  @doc ~S"""
  Starts a new Crawler with the given specification.
  If no caller is specified, the crawler will sent its data
  to the standard Coordinator `Koios.Coordinator`.
  """
  @spec start_crawler(Koios.CrawlerSpec.t()) :: {:ok, pid}
  def start_crawler(crawler_spec) do
    crawler_spec = case crawler_spec.caller do
      nil -> %Koios.CrawlerSpec{crawler_spec | caller: Koios.Coordinator}
      _ -> crawler_spec
    end
    DynamicSupervisor.start_child(
      Koios.CrawlerSupervisor,
      Koios.Crawler.child_spec(crawler_spec)
    )
  end
end
