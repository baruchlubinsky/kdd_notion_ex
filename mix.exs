defmodule KddNotionEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :kdd_notion_ex,
      version: "0.1.5",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:finch, "~> 0.16"},
      {:jason, "~> 1.4"}
    ]
  end
end
