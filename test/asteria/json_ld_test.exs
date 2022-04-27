defmodule Asteria.JsonLdTest do
  use ExUnit.Case, async: true

  test "scrape with one json+ld" do
    html = """
      <html>
        <body>
          <script type="application/ld+json">
            {
              "@context": "http://schema.org",
              "@type": "Person",
              "name": "John Doe"
            }
          </script>
        </body>
      </html>
    """
    result =  Asteria.JsonLd.extract(Floki.parse_document!(html))
    assert result == [%{
      "@context" => "http://schema.org",
      "@type" => "Person",
      "name" => "John Doe",
    }]
  end

  test "scrape without json+ld" do
    html = """
      <html>
        <body>
          <script>
            {
              "@context": "http://schema.org",
              "@type": "Person",
              "name": "John Doe"
            }
          </script>
        </body>
      </html>
    """
    result =  Asteria.JsonLd.extract(Floki.parse_document!(html))
    assert result == []
  end

  test "scrape with two json+ld" do
    html = """
      <html>
        <body>
          <script type="application/ld+json">
            {
              "@context": "http://schema.org",
              "@type": "Person",
              "name": "John Doe"
            }
          </script>
          <script type="application/ld+json">
            {
              "@context": "http://schema.org",
              "@type": "Person",
              "name": "John Smith"
            }
          </script>
        </body>
      </html>
    """
    result =  Asteria.JsonLd.extract(Floki.parse_document!(html))
    assert result == [
      %{
        "@context" => "http://schema.org",
        "@type" => "Person",
        "name" => "John Doe",
      },
      %{
        "@context" => "http://schema.org",
        "@type" => "Person",
        "name" => "John Smith",
      }
    ]
  end


  test "scrape with broken json+ld" do
    html = """
      <html>
        <body>
          <script type="application/ld+json">
            {
              "@context": "http://schema.org",
              "@type": "Person
              "name": "John Doe"
            }
          </script>
        </body>
      </html>
    """
    result =  Asteria.JsonLd.extract(Floki.parse_document!(html))
    assert result == []
  end

end
