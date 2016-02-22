defmodule HnProtocol.Mixfile do
  use Mix.Project

  def project do
    [app: :hn_protocol,
     version: "0.0.3",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [
        :logger,
        :httpoison,
        :ranch,
        :poison
      ],
      mod: {HnProtocol, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:poison, "~> 2.0"},
      {:httpoison, "~> 0.8"},
      {:ranch, "~> 1.2"},
      {:exrm, "~> 1.0.0-rc8"},

      # TODO remove this once new version of relx is released
      # https://github.com/bitwalker/exrm/issues/294
      {:cf, "~> 0.2", override: true},
      {:erlware_commons, github: "erlware/erlware_commons", override: true}
    ]
  end
end
