defmodule Koios.Scraper.SchemaScraper do
  @behaviour Koios.Scraper

  @impl true
  def scrape(_, {_, doc}, req) do
    schemas = Asteria.JsonLd.extract(doc) ++ Asteria.Microdata.extract(doc)
    IO.puts("#{Enum.count(schemas)} schemas found on #{req.url}")
    if Enum.count(schemas) > 0 do
      domain = URI.parse(req.url).host
      path = String.replace(URI.parse(req.url).path, "/", "-")
      File.write("dump/#{domain}+#{path}.json", Jason.encode!(schemas, pretty: true)) |> IO.inspect
    end

  end

end
