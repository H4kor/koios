defmodule Koios.Util.UrlUtilTest do
  use ExUnit.Case, async: true
  doctest Koios.Util.UrlUtil

  test "extract_links_from_document with links" do
    doc = Floki.parse_document!("
      <html>
        <body>
          <a href='foo.html'>foo</a>
          <a href='bar.html'>bar</a>
        </body>
      </html>"
    )
    assert ["foo.html", "bar.html"] == Koios.Util.UrlUtil.extract_links_from_document(doc)
  end

  test "extract_links_from_document without links" do
    doc = Floki.parse_document!("
      <html>
        <body>
          Hello World!
        </body>
      </html>"
    )
    assert [] == Koios.Util.UrlUtil.extract_links_from_document(doc)
  end

  test "extract_links_from_document with empty link" do
    doc = Floki.parse_document!("
      <html>
        <body>
          <a>bar</a>
        </body>
      </html>"
    )
    assert [] == Koios.Util.UrlUtil.extract_links_from_document(doc)
  end


end
