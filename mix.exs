defmodule Hrafn.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hrafn,
      version: "0.1.0",
      elixir: "~> 1.2",
      description: """
      Elixir Sentry client
      """,
      package: package,
      deps: deps
   ]
  end

  def package do
    [
      maintainers: ["Twined Networks"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/twined/hrafn"}
   ]
  end

  def application do
    [
      applications: [
        :idna,
        :hackney,
        :httpoison,
        :uuid
      ]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.8"},
      {:poison, "~> 2.0"},
      {:uuid, "~> 1.1.3"},
    ]
  end
end
