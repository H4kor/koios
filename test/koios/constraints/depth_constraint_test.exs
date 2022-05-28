defmodule Koios.DepthConstraintTest do
  use ExUnit.Case, async: false
  doctest Koios.DepthConstraint

  test "depth" do
    assert(:true == Koios.DepthConstraint.valid?(
      1, %Koios.CrawlRequest{url: "example.com", depth: 0})
    )
    assert(:true == Koios.DepthConstraint.valid?(
      1, %Koios.CrawlRequest{url: "example.com", depth: 1})
    )
    assert(:false == Koios.DepthConstraint.valid?(
      1, %Koios.CrawlRequest{url: "example.com", depth: 2})
    )
  end

end
