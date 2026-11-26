defmodule AntColony do
  alias AntColony.Ant

  def start_link(strategy, count, bounds, positions \\ %{}) do
    ants = for id <- 1..count, do: child_spec(id, bounds, positions[id])
    Supervisor.start_link(ants, strategy: strategy, max_restarts: 1_000)
  end

  def children(supervisor) do
    for {id, pid, :worker, _} <- Supervisor.which_children(supervisor), is_pid(pid), into: %{} do
      {id, pid}
    end
  end

  def add(supervisor, count, bounds) do
    last_id = supervisor |> children() |> Map.keys() |> Enum.max()

    Enum.each((last_id + 1)..(last_id + count), fn id ->
      {:ok, _pid} = Supervisor.start_child(supervisor, child_spec(id, bounds, nil))
    end)
  end

  def fail(supervisor, id) do
    before_failure = children(supervisor)
    old_pid = Map.fetch!(before_failure, id)
    Process.exit(old_pid, :kill)

    after_restart = await_restart(supervisor, id, old_pid)

    restarted_ids = for {id, pid} <- after_restart, before_failure[id] != pid, do: id

    {old_pid, after_restart[id], restarted_ids}
  end

  def change_strategy(supervisor, strategy, bounds) do
    positions = for {id, pid} <- children(supervisor), into: %{}, do: {id, Ant.position(pid)}

    :ok = Supervisor.stop(supervisor)
    start_link(strategy, map_size(positions), bounds, positions)
  end

  defp child_spec(id, bounds, position) do
    Supervisor.child_spec({Ant, {bounds, position}}, id: id)
  end

  defp await_restart(supervisor, id, old_pid) do
    ants = children(supervisor)

    pid = ants[id]

    if pid && pid != old_pid do
      ants
    else
      Process.sleep(5)
      await_restart(supervisor, id, old_pid)
    end
  end
end
