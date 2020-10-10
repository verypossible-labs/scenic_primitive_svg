defmodule ScenicPrimitiveSVG do
  alias ScenicPrimitiveSVG.Path

  def decode(svg) do
    XmlToMap.naive_map(svg)
    |> Map.get("svg")
    |> Map.get("#content")
    |> decode_content()
  end

  def decode_content(content) do
    content
    |> Enum.reduce([], &[decode_element(&1) | &2])
    |> List.flatten()
    |> Enum.reverse()
  end

  # Convert paths into Scenic.Primitive.Path
  def decode_element({"path", content}) when is_list(content) do
    Enum.reduce(content, [], &[Path.decode_element(&1) | &2])
  end

  def decode_element({"path", element}), do: Path.decode_element(element)
end
