# koios

This is not fit for any usage, at the moment. Don't even think about adding this to your project, it was written by a fool without prior knowledge of Elixir.g

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `koios` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:koios, "~> 0.1.0"}
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

**Coordinator** can have multiple crawlers sending data to them. Have multiple scrapers processing the data.

**Scraper** retrieve data (html) and process it in arbitrary ways.


```elixir
Koios.Crawler.start_link({"https://blog.libove.org/", 0, 10, self()})

Koios.DomainGraph.generate_dot_file("https://blog.libove.org", 50, "test.dot")

IEx.Helpers.recompile()


Koios.add_scraper(Koios.Scraper.SchemaScraper, nil)
Koios.start_crawler(%Koios.CrawlerSpec{url: "https://blog.libove.org", max_depth: 4, max_tasks: 400})

```