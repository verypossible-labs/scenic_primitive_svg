defmodule ScenicPrimitiveSVG.MixProject do
  use Mix.Project

  def project do
    [
      app: :scenic_primitive_svg,
      version: "0.1.0",
      elixir: "~> 1.10",
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
      {:scenic, "~> 0.10"},
      {:elixir_xml_to_map, "~> 2.0"},
      {:chameleon, "~> 2.2.0"}
    ]
  end
end
