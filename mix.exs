defmodule Koios.MixProject do
  use Mix.Project

  def project do
    [
      app: :koios,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      name: "Koios",
      docs: [
        main: "Koios",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Koios, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:floki, "~> 0.32.0"},
      {:hackney, "~> 1.13"},
      # test deps
      {:mox, "~> 1.0.1", only: [:test], runtime: false},
      # dev deps
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
    ]
  end
end
