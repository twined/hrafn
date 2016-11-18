defmodule Hrafn.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hrafn,
      version: "0.1.0",
      elixir: "~> 1.2",
      description: "Hrafn client for Twined projects",
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
        :plug,
        :uuid
      ]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.9"},
      {:poison, "~> 2.2 or ~> 3.0"},
      {:plug, "~> 1.2"},
      {:uuid, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end
end
