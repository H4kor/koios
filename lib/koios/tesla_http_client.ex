defmodule Koios.TeslaHttpClient do
  @behaviour Koios.HttpClient
  use Tesla

  plug Tesla.Middleware.FollowRedirects, max_redirects: 10

  @spec get_page(String.t) :: {:ok, String.t} | {:error, any}
  def get_page(url) do
    request = get(url)
    case request do
      {:ok, response} ->
        if ( response.status >= 200 && response.status < 300 )do
          {:ok, response.body}
        else
          {:error, {:status, response.status}}
        end
      {:error, error} -> {:error, error}
    end
  end
end
