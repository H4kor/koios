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

  test "extract with scope in scope" do
    html = """
      <div itemscope itemtype="https://schema.org/VisualArtwork">
          <link itemprop="sameAs" href="http://rdf.freebase.com/rdf/m.0439_q" />
          <h1 itemprop="name" lang="fr">La trahison des images </h1>
          <p>
              A <span itemprop="artform">painting</span> also known as
              <span>The Treason of Images</span> or
              <span itemprop="alternateName">The Treachery of Images</span>.
          </p>
          <img itemprop="image" src="http://upload.wikimedia.org/wikipedia/en/b/b9/MagrittePipe.jpg" />
          <div itemprop="description">
              <p>
                  The painting shows a pipe. Below it, Magritte painted,
                  <q lang="fr">Ceci n'est pas une pipe.</q>, French for
                  "This is not a pipe."
              </p>
              <p>
                  His statement is taken to mean that the painting itself is not a pipe.
                  The painting is merely an image of a pipe. Hence, the description,
                  "this is not a pipe."
              </p>
              <p>
                  Similarly, the image shown above is neither a pipe nor even a painting,
                  but rather a digital photograph.
              </p>
              <p>
                  The painting is sometimes given as an example of meta message conveyed
                  by paralanguage. Compare with Korzybski's <q>The word is not the thing</q>
                  and <q>The map is not the territory</q>.
          </div>
          <ul>
              <li>Artist:
                  <span itemprop="creator" itemscope itemtype="https://schema.org/Person">
                      <a itemprop="sameAs" href="https://www.freebase.com/m/06h88">
                          <span itemprop="name">René Magritte</span>
                      </a>
                  </span>
              </li>
              <li>Dimensions:
                  <span itemprop="width" itemscope itemtype="https://schema.org/Distance">940 mm</span> ×
                  <span itemprop="height" itemscope itemtype="https://schema.org/Distance">635 mm</span>
              </li>
              <li>Materials:
                  <span itemprop="artMedium">oil</span> on <span itemprop="artworkSurface">canvas</span>
              </li>
          </ul>
      </div>
    """
    result =  Asteria.Microdata.extract(Floki.parse_document!(html))
    assert result == [
      %{
        "@context" => "https://schema.org",
        "@type" => "VisualArtwork",
        "sameAs" => "http://rdf.freebase.com/rdf/m.0439_q",
        "name" => "La trahison des images",
        "artform" => "painting",
        "alternateName" => "The Treachery of Images",
        "image" => "http://upload.wikimedia.org/wikipedia/en/b/b9/MagrittePipe.jpg",
        "description" => "<p>\n              The painting shows a pipe. Below it, Magritte painted,\n              <q lang=\"fr\">Ceci n&#39;est pas une pipe.</q>, French for\n              &quot;This is not a pipe.&quot;\n          </p><p>\n              His statement is taken to mean that the painting itself is not a pipe.\n              The painting is merely an image of a pipe. Hence, the description,\n              &quot;this is not a pipe.&quot;\n          </p><p>\n              Similarly, the image shown above is neither a pipe nor even a painting,\n              but rather a digital photograph.\n          </p><p>\n              The painting is sometimes given as an example of meta message conveyed\n              by paralanguage. Compare with Korzybski&#39;s <q>The word is not the thing</q>\n              and <q>The map is not the territory</q>.\n      </p>",
        "creator" => %{
          "@context" => "https://schema.org",
          "@type" => "Person",
          "sameAs" => "https://www.freebase.com/m/06h88",
          "name" => "René Magritte"
        },
        "width" => %{
          "@context" => "https://schema.org",
          "@type" => "Distance",
          "value" => "940 mm"
        },
        "height" => %{
          "@context" => "https://schema.org",
          "@type" => "Distance",
          "value" => "635 mm"
        },
        "artMedium" => "oil",
        "artworkSurface" => "canvas"
      }
    ]
  end
end
