import Config

config :koios,
  http_client: Koios.MockHttpClient,
  retriever_timeout_ms: 0
