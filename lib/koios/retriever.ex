defmodule Koios.Retriever do
  use GenServer

  @http_client Application.get_env(:koios, :http_client)

  def start_link(opts\\[]) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @doc """
    Retrieves a URL and returns the response body.

    @param url The URL to retrieve.
    @return The response body.
  """
  def get_page(retriever, url) do
    GenServer.call(retriever, {:get_page, url}, :infinity)
  end

  @impl true
  def handle_call({:get_page, url}, from, state) do
    response = @http_client.get_page(url)
    GenServer.reply(from, response)
    Process.sleep(Application.get_env(:koios, :retriever_timeout_ms))
    {:noreply, state}
  end
end
