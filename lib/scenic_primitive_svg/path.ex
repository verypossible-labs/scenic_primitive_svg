defmodule ScenicPrimitiveSVG.Path do
  @commands ~r/[MZLHVCSQTAmzlhvcsqta]/
  @move ~w/M m/
  @close_path ~w/Z z/
  @line ~w/L l/
  @horizontal_line ~w/H h/
  @vertical_line ~w/V v/
  @curve ~w/C c/
  @short_curve ~w/S s/
  @quad ~w/Q q/
  @short_quad ~w/T t/
  @arc ~w/A a/

  def decode_element(element) do
    elements =
      element
      |> Map.get("-d")
      |> decode_data()

    case elements do
      {:ok, elements} ->
        opts = decode_properties(element)
        Scenic.Primitives.path_spec(elements, opts)
      error -> error
    end
  end

  def decode_properties(element) do
    []
    |> decode_fill(Map.get(element, "-fill"))
  end

  def decode_fill(opts, nil), do: opts
  def decode_fill(opts, fill) do
    fill = Chameleon.convert(fill, Chameleon.RGB)
    Keyword.put(opts, :fill, {fill.r, fill.g, fill.b})
  end

  def decode_data(data) when is_binary(data) do
    data
    |> split_commands()
    |> decode_data()
  end
  def decode_data(data) do
    decode_path_commands(data, [:begin], {0.0, 0.0})
  end

  def decode_path_commands([], path, _position), do: {:ok, Enum.reverse(path)}
  def decode_path_commands(paths, path, position) do
    with {:ok, tail, path, position} <- decode_path_command(paths, path, position) do
      decode_path_commands(tail, path, position)
    end
  end

  # Move to
  def decode_path_command([cmd, args | tail], path, {cx, cy})
   when cmd in @move do
    [x, y] = split_args(args)
    {x, y} = {to_num(x), to_num(y)}
    case cmd do
      "M" ->
        # Move absolute
        {:ok, tail, [{:move_to, x, y} | path], {x, y}}
      "m" ->
        # Move relative
        {x, y} = {cx + x, cy + y}
        {:ok, tail, [{:move_to, x, y} | path], {x, y}}
    end
  end

  # Close path
  def decode_path_command([cmd | tail], path, {cx, cy})
   when cmd in @close_path do
    {:ok, tail, [:close_path | path], {cx, cy}}
  end

  # Line
  def decode_path_command([cmd, args | tail], path, {cx, cy})
   when cmd in @line do
    [x, y] = split_args(args)
    {x, y} = {to_num(x), to_num(y)}
    case cmd do
      "L" ->
        # Move absolute
        {:ok, tail, [{:line_to, x, y} | path], {x, y}}
      "l" ->
        # Move relative
        {x, y} = {cx + x, cy + y}
        {:ok, tail, [{:line_to, x, y} | path], {x, y}}
    end
  end

  def decode_path_command([cmd, x | tail], path, {cx, cy})
   when cmd in @horizontal_line do
    x = String.trim(x) |> to_num()
    case cmd do
      "H" ->
        # Move absolute
        {:ok, tail, [{:line_to, x, cy} | path], {x, cy}}
      "h" ->
        # Move relative
        {x, y} = {cx + x, cy}
        {:ok, tail, [{:line_to, x, y} | path], {x, y}}
    end
  end

  def decode_path_command([cmd, y | tail], path, {cx, cy})
   when cmd in @vertical_line do
    y = String.trim(y) |> to_num()
    case cmd do
      "V" ->
        # Move absolute
        {:ok, tail, [{:line_to, cx, y} | path], {cx, y}}
      "v" ->
        # Move relative
        {x, y} = {cx, cy + y}
        {:ok, tail, [{:line_to, x, y} | path], {x, y}}
    end
  end

  # Curve
  def decode_path_command([cmd, args | tail], path, {cx, cy})
   when cmd in @curve do
    [x1, y1, x2, y2, x, y] = split_args(args) |> Enum.map(&to_num/1)
    case cmd do
      "C" ->
        # Move absolute
        {:ok, tail, [{:bezier_to, x1, y1, x2, y2, x, y} | path], {x, y}}
      "c" ->
        # Move relative
        {x1, y1} = {cx + x1, cy + y1}
        {x2, y2} = {cx + x2, cy + y2}
        {x, y} = {cx + x, cy + y}
        {:ok, tail, [{:bezier_to, x1, y1, x2, y2, x, y} | path], {x, y}}
    end
  end

  def decode_path_command([cmd, args | tail], path, {cx, cy})
   when cmd in @short_curve do
    [x2, y2, x, y] = split_args(args)
    {x2, y2} = {to_num(x2), to_num(y2)}
    {x, y} = {to_num(x), to_num(y)}
    {x1, y1} = {x2, y2}

    case cmd do
      "S" ->
        # Move absolute
        {:ok, tail, [{:bezier_to, x1, y1, x2, y2, x, y} | path], {x, y}}
      "s" ->
        # Move relative
        {x1, y1} = {cx + x1, cy + y1}
        {x2, y2} = {x1 + x2, y1 + y2}
        {x, y} = {x2 + x, y2 + y}
        {:ok, tail, [{:bezier_to, x1, y1, x2, y2, x, y} | path], {x, y}}
    end
  end

  # Quad
  def decode_path_command([cmd, args | tail], path, {cx, cy})
   when cmd in @quad do
    case cmd do
      "Q" ->
        # Move absolute
        [x1, y1, x, y] = split_args(args)
        {x1, y1} = {to_num(x1), to_num(y1)}
        {x, y} = {to_num(x), to_num(y)}
        {:ok, tail, [{:quadratic_to, x1, y1, x, y} | path], {x, y}}
      "q" ->
        # Move relative
        [x, y] = split_args(args)
        {x, y} = {to_num(x), to_num(y)}
        {x1, y1} = {cx + x, cy + y}
        {x, y} = {x1 + x, y1 + y}
        {:ok, tail, [{:quadratic_to, x1, y1, x, y} | path], {x, y}}
    end
  end

  def decode_path_command([cmd, args | tail], path, {cx, cy})
   when cmd in @short_quad do
    [x, y] = split_args(args)
    {x, y} = {to_num(x), to_num(y)}
    {x1, y1} = {x, y}
    case cmd do
      "T" ->
        # Move absolute
        {:ok, tail, [{:quadratic_to, x1, y1, x, y} | path], {x, y}}
      "t" ->
        # Move relative
        {x1, y1} = {cx + x1, cy + y1}
        {x, y} = {x1 + x, y1 + y}
        {:ok, tail, [{:quadratic_to, x1, y1, x, y} | path], {x, y}}
    end
  end

  # Arc
  def decode_path_command([cmd, args | tail], path, {cx, cy})
   when cmd in @arc do
    [rx, ry, rot, x, y] = split_args(args)
    {rx, ry} = {to_num(rx), to_num(ry)}
    rot = to_num(rot)
    {x, y} = {to_num(x), to_num(y)}
    case cmd do
      "A" ->
        # Move absolute
        {:ok, tail, [{:arc_to, rx, ry, x, y, rot} | path], {x, y}}
      "a" ->
        # Move relative
        {x, y} = {cx + x, cy + y}
        {:ok, tail, [{:arc_to, rx, ry, x, y, rot} | path], {x, y}}
    end
  end

  def decode_path_command([" " | tail], path, pos),
    do: {:ok, tail, path, pos}

  def split_commands(string) do
    string =
      string
      |> String.trim()
      |> String.replace("\n", "")
      |> String.replace("\t", "")

    Regex.split(@commands, string, trim: true, include_captures: true)
  end

  def split_args(string) do
    Regex.split(~r/[\s,]/, string, trim: true)
    |> Enum.map(&Regex.split(~r/(?=-)/, &1, trim: true))
    |> List.flatten()
  end

  def to_num(str) when is_binary(str) do
    {int, _} = Float.parse(str)
    int
  end
end
