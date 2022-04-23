Mox.defmock(Koios.MockHttpClient, for: Koios.HttpClient)
Application.put_env(:koios, :http_client, Koios.MockHttpClient)

ExUnit.start()
