# koios

This is not fit for any usage at the moment.
Don't even think about adding this to your project, it was written by a fool without prior knowledge of Elixir.

**TODO: Add description**
## Architecture

The **RetrieverRegistry** provides **Retriever**s to be used for accessing website data.

**Retriever** are domain specific to enforce requests limits per domain.

A **Crawler** takes a URL/Domain and uses the **Retriever** to download all pages in a breath-first fashion.

A **Coordinator** can have multiple crawlers sending data to them and multiple scrapers processing the data.

A **Scraper** retrieves data (html) and process it in arbitrary ways.


```elixir
Koios.add_scraper(My.Scraper, nil)
Koios.add_scraper(Another.Scraper, nil)
Koios.build_crawler("https://blog.libove.org")
|> Koios.add_constraint(Koios.DomainConstraint, "**.libove.org")
|> Koios.add_constraint(Koios.DepthConstraint, 4)
|> Koios.max_tasks(400)
|> Koios.start_crawler
```