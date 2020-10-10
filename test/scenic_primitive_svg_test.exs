defmodule ScenicPrimitiveSVGTest do
  use ExUnit.Case
  doctest ScenicPrimitiveSVG

  # test "can parse simple svg" do
  #   "test/fixtures/smile.svg"
  #   |> File.read!()
  #   |> ScenicPrimitiveSVG.decode()
  # end

  test "can parse svg with styles" do
    "test/fixtures/style.svg"
    |> File.read!()
    |> ScenicPrimitiveSVG.decode()
  end
end
