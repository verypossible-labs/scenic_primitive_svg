defmodule Example.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Scenic.ViewPort

  import Scenic.Primitives



  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, opts) do
    # get the width and height of the viewport. This is to demonstrate creating
    # a transparent full-screen rectangle to catch user input
    # {:ok, %ViewPort.Status{size: {width, height}}} = ViewPort.info(opts[:viewport])

    svg_path = "/Users/jschneck/dev/verypossible-labs/scenic_primitive_svg/test/fixtures/style.svg"
    svg = File.read!(svg_path) |> ScenicPrimitiveSVG.decode()

    graph =
      Graph.build(font: :roboto, font_size: 12)
      |> add_specs_to_graph(svg)

    {:ok, graph, push: graph}
  end
end
