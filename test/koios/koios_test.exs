defmodule KoiosTest do
  use ExUnit.Case, async: false
  doctest Koios

  test "add_constraint" do
    crawler = Koios.build_crawler("https://example.com")
    |> Koios.add_constraint(Koios.DepthConstraint, 1)
    assert Enum.count(crawler.constraints) == 1
    assert Enum.member?(
      crawler.constraints,
      {Koios.DepthConstraint, 1}
    ) == :true
  end

  test "add_constraint multiple_constraints" do
    crawler = Koios.build_crawler("https://example.com")
    |> Koios.add_constraint(Koios.DepthConstraint, 1)
    |> Koios.add_constraint(Koios.DepthConstraint, 2)
    assert Enum.count(crawler.constraints) == 2
    assert Enum.member?(
      crawler.constraints,
      {Koios.DepthConstraint, 1}
    ) == :true
    assert Enum.member?(
      crawler.constraints,
      {Koios.DepthConstraint, 2}
    ) == :true
    assert Enum.member?(
      crawler.constraints,
      {Koios.DepthConstraint, 3}
    ) == :false
  end

  test "set max_tasks" do
    crawler = Koios.build_crawler("https://example.com")
    |> Koios.max_tasks(2)
    assert crawler.max_tasks == 2
  end

end
