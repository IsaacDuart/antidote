defmodule AntColony.Terminal do
  alias AntColony.Terminal.{Commands, View}

  def run do
    :ok = :logger.set_primary_config(:level, :none)
    columns = Owl.IO.columns()
    rows = Owl.IO.rows()
    width = min(columns || 56, 56)
    height = min(max((rows || 24) - 13, 4), 11)
    bounds = {max(width - 4, 1), height}
    live = (columns || 0) >= 32 and (rows || 0) >= height + 13

    strategy = :one_for_one
    count = 50
    {:ok, supervisor} = AntColony.start_link(strategy, count, bounds)

    state = %{
      supervisor: supervisor,
      strategy: strategy,
      bounds: bounds,
      demo_ant: count,
      width: width,
      live: live,
      failures: 0,
      restarts: 0,
      highlight: nil,
      message: "Cada ponto é um processo GenServer."
    }

    if live, do: IO.write("\e[2J\e[H")
    prompt(state)
  end

  defp prompt(state) do
    View.render(state, :prompt)
    terminal = self()
    spawn_link(fn -> send(terminal, {:command, read_command()}) end)
    wait_for_command(state)
  end

  defp wait_for_command(state) do
    refresh = if state.live, do: 150, else: :infinity

    receive do
      {:command, "q"} ->
        if state.live, do: IO.write("\r\e[K")
        Supervisor.stop(state.supervisor)

      {:command, key} ->
        prompt(Commands.handle(state, key))
    after
      refresh ->
        View.render(state, :refresh)
        wait_for_command(state)
    end
  end

  defp read_command do
    case IO.gets("") do
      line when is_binary(line) -> line |> String.trim() |> String.downcase()
      _ -> "q"
    end
  end
end
