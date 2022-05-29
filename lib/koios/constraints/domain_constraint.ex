defmodule Koios.DomainConstraint do
  @behaviour Koios.CrawlerConstraint

  @impl true
  @spec valid?(String.t, Koios.CrawlRequest.t) :: boolean
  @spec valid?([String.t], Koios.CrawlRequest.t) :: boolean

  def valid?(domains, request) when is_list(domains) do
    Enum.any?(domains, &(Koios.DomainConstraint.valid?(&1, request)))
  end

  def valid?(domain, request) when is_binary(request.url) do
    uri = URI.parse(request.url)
    if uri.host != nil do
      domain_parts = Enum.reverse(String.split(domain, "."))
      uri_parts = Enum.reverse(String.split(uri.host, "."))
      compare(uri_parts, domain_parts)
    else
      false
    end
  end
  def valid?(_, %{url: nil}), do: false

  # catch all subdomain with **
  defp compare(_, ["**" | _]), do: true

  # wildcard
  defp compare([_ | a_tail], ["*" | b_tail]), do: compare(a_tail, b_tail)
  # match with one missing part
  defp compare([], ["*"]), do: true

  # general case
  defp compare([a | a_tail], [b | b_tail]), do: a == b and compare(a_tail, b_tail)
  defp compare([a], [b]), do: a == b
  defp compare([], []), do: true
  defp compare(_, []), do: false
  defp compare([], _), do: false
end
