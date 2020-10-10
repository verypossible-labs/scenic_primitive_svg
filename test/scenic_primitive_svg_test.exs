defmodule ScenicPrimitiveSVGTest do
  use ExUnit.Case
  doctest ScenicPrimitiveSVG

  test "can parse simple svg" do
    svg =
      "test/fixtures/smile.svg"
      |> File.read!()
      |> ScenicPrimitiveSVG.decode()
    assert svg
  end
end
