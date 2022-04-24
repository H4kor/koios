# Scraper

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `scraper` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:scraper, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/scraper>.


## Architecture

**RetrieverRegistry** provides **Retriever**s to be used for accessing website data

**Retriever** are domain specific to enforce requests limits per domain.

**Finder** takes an initial URL and searches for domains in a breath-first fashion

**Crawler** takes a URL/Domain and uses the **Retriever** to download all pages in a breath-first fashion


```elixir
Koios.Finder.find_on_page("https://blog.libove.org/", 1, self())

Koios.DomainGraph.generate_dot_file("https://blog.libove.org", 1, "test.dot")

IEx.Helpers.recompile()
```