defmodule ScenicPrimitiveSVG.PathTest do
  use ExUnit.Case
  doctest ScenicPrimitiveSVG.Path

  alias ScenicPrimitiveSVG.Path

  describe "string parsing" do
    test "split args" do
      assert ["10", "20"] = Path.split_args("10,20")
      assert ["10", "20"] = Path.split_args("10\n20")
      assert ["10", "20"] = Path.split_args("10\t20")
      assert ["10", "20"] = Path.split_args("10 20")
      assert ["-10", "-20"] = Path.split_args("-10-20")
      assert ["10", "-20", "30", "40"] = Path.split_args("10-20,30 40")
    end
  end

  describe "decode" do
    test "move absolute" do
      assert {:ok, [:begin, {:move_to, 10.0, 20.0}]} = Path.decode_data("M10 20")
    end

    test "move relative" do
      assert {:ok, [:begin, {:move_to, 10.0, 20.0}, {:move_to, 15.0, 25.0}]} = Path.decode_data("M10 20 m5 5")
    end

    test "close path" do
      assert {:ok, [:begin, :close_path]} = Path.decode_data("Z")
    end

    test "line absolute" do
      assert {:ok, [:begin, {:line_to, 10.0, 20.0}]} = Path.decode_data("L10 20")
    end

    test "line relative" do
      assert {:ok, [:begin, {:line_to, 10.0, 20.0}, {:line_to, 15.0, 25.0}]} = Path.decode_data("L10 20 l5 5")
    end

    test "horizontal line absolute" do
      assert {:ok, [:begin, {:line_to, 10.0, 0.0}]} = Path.decode_data("H10")
    end

    test "horizontal line relative" do
      assert {:ok, [:begin, {:line_to, 10.0, 0.0}, {:line_to, 15.0, 0.0}]} = Path.decode_data("H10 h5")
    end

    test "vertical line absolute" do
      assert {:ok, [:begin, {:line_to, 0.0, 10.0}]} = Path.decode_data("V10")
    end

    test "vertical line relative" do
      assert {:ok, [:begin, {:line_to, 0.0, 10.0}, {:line_to, 0.0, 15.0}]} = Path.decode_data("V10 v5")
    end

    test "curve absolute" do
      assert {:ok, [:begin, {:bezier_to, 0.0, 10.0, 20.0, 30.0, 40.0, 50.0}]} = Path.decode_data("C0 10 20 30 40 50")
    end

    test "curve relative" do
      assert {:ok, [:begin, {:bezier_to, 0.0, 10.0, 20.0, 30.0, 40.0, 50.0}, {:bezier_to, 45.0, 55.0, 50.0, 60.0, 60.0, 70.0}]} = Path.decode_data("C0 10 20 30 40 50 c5 5 10 10")
    end

    test "curve short absolute" do
      assert {:ok, [:begin, {:bezier_to, 0.0, 10.0, 0.0, 10.0, 20.0, 30.0}]} = Path.decode_data("S0 10 20 30")
    end

    test "curve short relative" do
      assert {:ok, [:begin, {:bezier_to, 0.0, 10.0, 0.0, 10.0, 20.0, 30.0}, {:bezier_to, 25.0, 35.0, 30.0, 40.0, 40.0, 50.0}]} = Path.decode_data("S0 10 20 30 s5 5 10 10")
    end

    test "quad absolute" do
      assert {:ok, [:begin, {:quadratic_to, 0.0, 10.0, 20.0, 30.0}]} = Path.decode_data("Q0 10 20 30")
    end

    test "quad relative" do
      assert {:ok, [:begin, {:quadratic_to, 0.0, 10.0, 20.0, 30.0}, {:quadratic_to, 25.0, 35.0, 30.0, 40.0}]} = Path.decode_data("Q0 10 20 30 q5 5")
    end

    test "quad short absolute" do
      assert {:ok, [:begin, {:quadratic_to, 0.0, 10.0, 0.0, 10.0}]} = Path.decode_data("T0 10")
    end

    test "quad short relative" do
      assert {:ok, [:begin, {:quadratic_to, 20.0, 30.0, 20.0, 30.0}, {:quadratic_to, 25.0, 35.0, 30.0, 40.0}]} = Path.decode_data("T20 30 t5 5")
    end

    test "arch absolute" do
      assert {:ok, [:begin, {:arc_to, 10.0, 20.0, 40.0, 50.0, 30.0}]} = Path.decode_data("A10 20 30 40 50")
    end

    test "arch relative" do
      assert {:ok, [:begin, {:arc_to, 10.0, 20.0, 40.0, 50.0, 30.0}, {:arc_to, 5.0, 5.0, 50.0, 60.0, 30.0}]} = Path.decode_data("A10 20 30 40 50 a5 5 30 10 10")
    end
  end
end
