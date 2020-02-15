defmodule CollabiqId.MixProject do
  use Mix.Project

  def project do
    [
      app: :collabiq_id,
      version: "0.1.1",
      elixir: "~> 1.9",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_uuid, "~> 1.2"},
      {:excoveralls, "~> 0.12.2", only: :test},
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      {:hashids, "~> 2.0"}
    ]
  end
end
