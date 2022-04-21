defmodule Koios.Retriever do

  def start_link() do
    Task.start_link(fn -> loop() end)
  end

  def get_page(retriever, url) do
    send retriever, {:get_page, url, self()}
    receive do
      result ->
        result
    end

  end

  defp loop() do
    receive do
      {:get_page, url, caller} ->
        send caller, Koios.HTTPClient.get_page(url)
        # TODO: wait to avoid flooding
        loop()
    # after
    #   10_000 ->
    #     nil # TOOD: kill the retriever
    end
  end
end
