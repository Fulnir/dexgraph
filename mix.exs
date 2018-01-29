defmodule Dexgraph.MixProject do
  use Mix.Project

  def project do
    [
      app: :dexgraph,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      docs: docs() 
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
    [{:ex_doc, "~> 0.17", only: :dev, runtime: false},        # mix docs erzeugt die Documentation
    {:credo, "~> 0.9.0-rc1", only: [:dev, :test]},  # mix credo übperprüft den Styleguide
    {:ex_dash, "~> 0.1.5", only: :dev},         # For Dash  mix docs.dash
    {:inch_ex, "~> 0.5", only: [:dev, :test]}, # mix inch
    {:mix_test_watch, "~> 0.2", only: :dev},  # Automatically run your Elixir project's tests each time you save a file.
    {:poison, "~> 2.0", override: true},
    {:httpoison, "~> 1.0"},
    {:bunt, "~> 0.2.0"}
  ]
  end

  defp docs do
    [
      name: "Dexgraph",
      main: "README",
      extra_section: "guides",
      assets: "guides/images",
      formatters: ["html", "epub"],
      logo: "guides/images/logo.png",
      source_url: "/Users/ed/Documents/Developing/Elixir/project-codex/dexgraph",
      homepage_url: "https://bitbucket.org/Fulnir/dexgraph",
      extras: [
        "README.md",
        "guides/overview.md"
      ]
    ]
  end
end
