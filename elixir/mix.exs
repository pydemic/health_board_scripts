defmodule HBS.MixProject do
  use Mix.Project

  def project do
    [
      app: :hbs,
      version: "0.0.1",
      elixir: "~> 1.10",
      elixirc_paths: ["lib"],
      compilers: Mix.compilers(),
      start_permanent: false,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {HBS.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.4.1", only: :test, runtime: false},
      {:floki, "~> 0.29.0", only: [:dev, :test]},
      {:hackney, "~> 1.16.0"},
      {:jason, "~> 1.2.2"},
      {:nimble_csv, "~> 1.1.0"},
      {:tesla, "~> 1.3.3"}
    ]
  end
end
