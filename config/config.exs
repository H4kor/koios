import Config

config :koios,
  http_client: Koios.TeslaHttpClient

config :tesla,
  adapter: Tesla.Adapter.Hackney


import_config "#{config_env()}.exs"
