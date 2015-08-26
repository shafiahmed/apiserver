defmodule ApiServer.Mixfile do
  use Mix.Project

  def project do
    [app: :api_server,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {ApiServer, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :httpoison, :gproc, :econfig]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 0.17"},
     {:phoenix_html, "~> 2.0"},
     {:phoenix_live_reload, "~> 0.6", only: :dev},
     {:cowboy, "~> 1.0"},
     {:poison, "~> 1.4.0"},
     {:corsica, "~> 0.2"},
     {:httpoison, "~> 0.7.2"},
     { :epgsql, github: "epgsql/epgsql"},
     { :poolboy, github: "devinus/poolboy" },
     { :econfig, github: "benoitc/econfig" },
     { :yomel, "~> 0.2.2" }
  ]
  end
end