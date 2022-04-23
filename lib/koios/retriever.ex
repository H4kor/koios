defmodule Koios.Retriever do
  @http_client Application.get_env(:koios, :http_client)
  use Task

  @spec start_link :: {:ok, pid}
  def start_link() do
    Task.start_link(fn -> loop() end)
  end

  @doc """
    Retrieves a URL and returns the response body.

    @param url The URL to retrieve.
    @return The response body.
  """
  def get_page(retriever, url) do
    send retriever, {:get_page, url, self()}
    receive do
      result -> result
    end

  end

  defp loop() do
    receive do
      {:get_page, url, caller} ->
        send caller, @http_client.get_page(url)
        Process.sleep(Application.get_env(:koios, :retriever_timeout_ms))
        loop()
    # after
    #   10_000 ->
    #     nil # TOOD: kill the retriever
    end
  end
end
