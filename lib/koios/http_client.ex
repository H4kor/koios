defmodule Koios.HttpClient do
  @callback get_page(String.t) :: {:ok, String.t} | {:error, any}
end
