import Config

config :koios,
  http_client: Koios.TeslaHttpClient,
  retriever_timeout_ms: 2_000
config :tesla,
  adapter: Tesla.Adapter.Hackney


import_config "#{config_env()}.exs"
