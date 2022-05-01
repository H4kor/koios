# defmodule Koios.Scraper.SchemaScraperTest do
#   use ExUnit.Case, async: true

#   test "scrape with one json+ld" do
#     html = """
#       <html>
#         <body>
#           <script type="application/ld+json">
#             {
#               "@context": "http://schema.org",
#               "@type": "Person",
#               "name": "John Doe"
#             }
#           </script>
#         </body>
#       </html>
#     """
#     result =  Koios.Scraper.SchemaScraper.scrape(
#       {html, Floki.parse_document!(html)},
#       nil
#     )
#     assert result == [%{
#       "@context" => "http://schema.org",
#       "@type" => "Person",
#       "name" => "John Doe",
#     }]
#   end
# end
