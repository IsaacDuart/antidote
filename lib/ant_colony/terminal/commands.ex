defmodule AntColony.Terminal.Commands do
  @highlight_duration_ms 3_000

  def handle(state, "a") do
    AntColony.add(state.supervisor, 10, state.bounds)
    %{state | message: "10 novos processos supervisionados."}
  end

  def handle(state, "f"), do: fail_ant(state)

  def handle(state, "1"), do: change_strategy(state, :one_for_one)
  def handle(state, "2"), do: change_strategy(state, :one_for_all)
  def handle(state, "3"), do: change_strategy(state, :rest_for_one)
  def handle(state, _key), do: state

  defp fail_ant(state) do
    {old_pid, new_pid, restarted_ids} = AntColony.fail(state.supervisor, state.demo_ant)
    previous_process = :erlang.pid_to_list(old_pid)
    new_process = :erlang.pid_to_list(new_pid)

    restarted_label =
      case Enum.min_max(restarted_ids) do
        {id, id} -> "F#{id}"
        {first, last} -> "F#{first}–F#{last}"
      end

    message = "Reinício: #{restarted_label} · #{previous_process} → #{new_process}"

    %{
      state
      | failures: state.failures + 1,
        restarts: state.restarts + length(restarted_ids),
        highlight: {restarted_ids, System.monotonic_time(:millisecond) + @highlight_duration_ms},
        message: message
    }
  end

  defp change_strategy(state, strategy) when state.strategy == strategy, do: state

  defp change_strategy(state, strategy) do
    {:ok, supervisor} = AntColony.change_strategy(state.supervisor, strategy, state.bounds)

    %{
      state
      | supervisor: supervisor,
        strategy: strategy,
        highlight: nil,
        message: "Novo supervisor iniciado com #{strategy}."
    }
  end
end
