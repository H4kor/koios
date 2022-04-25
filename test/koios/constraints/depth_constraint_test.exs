defmodule Koios.DepthConstraintTest do
  use ExUnit.Case, async: false
  doctest Koios.DepthConstraint

  test "construct config" do
    assert(1 == %Koios.DepthConstraint{max_depth: 1}.max_depth)
  end

  test "test valid" do
    assert(true == Koios.DepthConstraint.valid?(
      %Koios.DepthConstraint{max_depth: 1}, %Koios.CrawlRequest{url: "example.com", depth: 0})
    )
    assert(false == Koios.DepthConstraint.valid?(
      %Koios.DepthConstraint{max_depth: 1}, %Koios.CrawlRequest{url: "example.com", depth: 2})
    )
  end

end
