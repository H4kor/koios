defmodule Koios.Retriever do
  @http_client Application.get_env(:koios, :http_client)
  use Task

  def start_link() do
    Task.start_link(fn -> loop() end)
  end

  def get_page(retriever, url) do
    send retriever, {:get_page, url, self()}
    receive do
      result -> result
    end

  end

  defp loop() do
    receive do
      {:get_page, url, caller} ->
        IO.puts("Get page: #{url}")
        send caller, @http_client.get_page(url)
        Process.sleep(2_000)
        loop()
    # after
    #   10_000 ->
    #     nil # TOOD: kill the retriever
    end
  end
end
