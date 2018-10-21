defmodule Base64.MixProject do
  use Mix.Project

  def project do
    [
      app: :base64,
      version: "0.1.0",
      elixir: "~> 1.7.3",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
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
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:exprof, "~> 0.2.0"}
    ]
  end

  defp escript do
    [
      main_module: Base64.CLI
    ]
  end
end
