defmodule Koios.DomainConstraintTest do
  use ExUnit.Case, async: false
  doctest Koios.DomainConstraint

  test "fixed domain" do
    assert Koios.DomainConstraint.valid?(
      "example.com", %Koios.CrawlRequest{url: "https://example.com"}
    ) == :true
    assert Koios.DomainConstraint.valid?(
      "example.com", %Koios.CrawlRequest{url: "https://example.com/bar/baz"}
    ) == :true
    assert Koios.DomainConstraint.valid?(
      "example.com", %Koios.CrawlRequest{url: "https://example2.com"}
    ) == :false
    assert Koios.DomainConstraint.valid?(
      "example.com", %Koios.CrawlRequest{url: "https://bar.example.com"}
    ) == :false
  end

  test "multiple domains" do
    assert Koios.DomainConstraint.valid?(
      ["foo.com", "bar.com"], %Koios.CrawlRequest{url: "https://example2.com"}
    ) == :false
    assert Koios.DomainConstraint.valid?(
      ["foo.com", "bar.com"], %Koios.CrawlRequest{url: "https://foo.com"}
    ) == :true
    assert Koios.DomainConstraint.valid?(
      ["foo.com", "bar.com"], %Koios.CrawlRequest{url: "https://bar.com"}
    ) == :true
  end

  test "all subdomains" do
    assert Koios.DomainConstraint.valid?(
      "**.foo.com", %Koios.CrawlRequest{url: "https://foo.com"}
    ) == :true
    assert Koios.DomainConstraint.valid?(
      "**.foo.com", %Koios.CrawlRequest{url: "https://bar.foo.com"}
    ) == :true
    assert Koios.DomainConstraint.valid?(
      "**.foo.com", %Koios.CrawlRequest{url: "https://a.b.c.d.e.foo.com"}
    ) == :true
    assert Koios.DomainConstraint.valid?(
      "**.foo.com", %Koios.CrawlRequest{url: "https://a.b.c.d.e.com"}
    ) == :false
  end

  test "single subdomain" do
    assert Koios.DomainConstraint.valid?(
      "*.foo.com", %Koios.CrawlRequest{url: "https://foo.com"}
    ) == :true
    assert Koios.DomainConstraint.valid?(
      "*.foo.com", %Koios.CrawlRequest{url: "https://bar.foo.com"}
    ) == :true
    assert Koios.DomainConstraint.valid?(
      "*.foo.com", %Koios.CrawlRequest{url: "https://d.e.foo.com"}
    ) == :false
    assert Koios.DomainConstraint.valid?(
      "*.foo.com", %Koios.CrawlRequest{url: "https://a.b.c.d.e.com"}
    ) == :false
    assert Koios.DomainConstraint.valid?(
      "bar.*.foo.com", %Koios.CrawlRequest{url: "https://bar.foo.com"}
    ) == :false
    assert Koios.DomainConstraint.valid?(
      "bar.*.foo.com", %Koios.CrawlRequest{url: "https://bar.baz.foo.com"}
    ) == :true
  end

  test "nil url" do
    assert Koios.DomainConstraint.valid?(
      "example.com", %Koios.CrawlRequest{url: nil}
    ) == :false
  end

  test "relative url" do
    assert Koios.DomainConstraint.valid?(
      "example.com", %Koios.CrawlRequest{url: "/foo/bar"}
    ) == :false
  end

end
