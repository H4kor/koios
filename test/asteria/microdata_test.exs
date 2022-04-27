defmodule Asteria.MicrodataTest do
  use ExUnit.Case, async: true

  test "extract with one microdata object" do
    html = """
      <div itemscope itemtype ="https://schema.org/Movie">
        <h1 itemprop="name">Avatar</h1>
        <span>Director: <span itemprop="director">James Cameron</span> (born August 16, 1954)</span>
        <span itemprop="genre">Science fiction</span>
        <a href="../movies/avatar-theatrical-trailer.html" itemprop="trailer">Trailer</a>
      </div>
    """
    result =  Asteria.Microdata.extract(Floki.parse_document!(html))
    assert result == [
      %{
        "@context" => "https://schema.org",
        "@type" => "Movie",
        "name" => "Avatar",
        "director" => "James Cameron",
        "genre" => "Science fiction",
        "trailer" => "../movies/avatar-theatrical-trailer.html",
      }
    ]
  end
end
