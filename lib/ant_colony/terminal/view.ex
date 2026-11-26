defmodule AntColony.Terminal.View do
  alias AntColony.Ant
  alias Owl.{Box, Data}

  @colors [:cyan, :green, :yellow, :magenta]
  @blink_interval_ms 300

  def render(state, mode) do
    ants = AntColony.children(state.supervisor)
    board = board_panel(state, ants)

    lines =
      if mode == :refresh do
        Data.lines(board)
      else
        Data.lines(board) ++ Data.lines(status_panel(state, ants)) ++ state.controls
      end

    write_frame(lines, state.live, mode)
  end

  defp board_panel(state, ants) do
    {width, height} = state.bounds
    {highlighted, marker} = active_highlight(state.highlight, state.live)

    ants_by_position =
      Enum.group_by(ants, fn {_id, pid} -> Ant.position(pid) end, fn {id, _pid} -> id end)

    rows =
      for y <- 1..height do
        for x <- 1..width, do: cell(ants_by_position[{x, y}], highlighted, marker)
      end

    panel(rows, " Colônia de formigas ", :cyan, state.width)
  end

  defp active_highlight(nil, _live), do: {[], nil}

  defp active_highlight({ids, deadline}, live) do
    remaining = deadline - System.monotonic_time(:millisecond)

    cond do
      remaining <= 0 ->
        {[], nil}

      live and rem(remaining - 1, 2 * @blink_interval_ms) < @blink_interval_ms ->
        {ids, Data.tag("◇", :white)}

      true ->
        {ids, Data.tag("◆", :light_red)}
    end
  end

  defp status_panel(state, ants) do
    pid_label = :erlang.pid_to_list(ants[state.demo_ant])
    strategy = Data.tag(Atom.to_string(state.strategy), :magenta)

    counters =
      "Ativas #{map_size(ants)}  ·  Falhas #{state.failures}  ·  Reinícios #{state.restarts}"

    rows = [[strategy, "  ·  F#{state.demo_ant} #{pid_label}"], counters, state.message]

    panel(rows, " Supervisor OTP ", :magenta, state.width)
  end

  def controls(width) do
    strategies =
      if width < 44 do
        [shortcuts("1": "one_for_one", "2": "one_for_all"), shortcuts("3": "rest_for_one")]
      else
        [shortcuts("1": "one_for_one", "2": "one_for_all", "3": "rest_for_one")]
      end

    [shortcuts(a: "+10", f: "Falhar")] ++
      strategies ++ [[shortcuts(q: "Sair"), Data.tag("  ·  Enter", :light_black)]]
  end

  defp write_frame(lines, false, _mode), do: lines |> Data.unlines() |> Owl.IO.puts()

  defp write_frame(lines, true, mode) do
    screen =
      Enum.with_index(lines, 1)
      |> Enum.map(fn {line, row} ->
        ["\e[#{row};1H\e[2K", line |> Data.to_chardata() |> IO.ANSI.format()]
      end)

    if mode == :prompt do
      IO.write(["\e[?7l", screen, "\e[#{length(lines) + 1};1H\e[J› \e[?7h"])
    else
      IO.write(["\e7\e[?7l", screen, "\e[?7h\e8"])
    end
  end

  defp panel(rows, title, color, width) do
    rows
    |> Data.unlines()
    |> Box.new(
      title: Data.tag(title, color),
      border_style: :solid_rounded,
      border_tag: color,
      horizontal_align: :left,
      padding_x: 1,
      min_width: width,
      max_width: width,
      truncate_lines: true
    )
  end

  defp cell(nil, _highlighted, _marker), do: Data.tag("·", :light_black)

  defp cell(ids, highlighted, marker) do
    if Enum.any?(ids, fn id -> id in highlighted end) do
      marker
    else
      color_index = rem(Enum.min(ids), length(@colors))
      Data.tag("●", Enum.at(@colors, color_index))
    end
  end

  defp shortcuts(commands) do
    Enum.map_intersperse(commands, "  ", fn {key, action} ->
      [Data.tag(Atom.to_string(key), :yellow), " ", action]
    end)
  end
end
