defmodule AntColony.Ant do
  use GenServer

  def start_link(args), do: GenServer.start_link(__MODULE__, args)
  def position(pid), do: GenServer.call(pid, :position)

  @impl true
  def init({bounds, initial_position}) do
    {width, height} = bounds
    position = initial_position || {:rand.uniform(width), :rand.uniform(height)}
    schedule_step()
    {:ok, %{position: position, bounds: bounds}}
  end

  @impl true
  def handle_call(:position, _from, state) do
    {:reply, state.position, state}
  end

  @impl true
  def handle_info(:step, state) do
    {x, y} = state.position
    {width, height} = state.bounds
    {dx, dy} = Enum.random([{1, 0}, {-1, 0}, {0, 1}, {0, -1}])

    position = {limit(x + dx, width), limit(y + dy, height)}
    schedule_step()
    {:noreply, %{state | position: position}}
  end

  defp limit(value, upper_bound), do: min(max(value, 1), upper_bound)
  defp schedule_step, do: Process.send_after(self(), :step, 120 + :rand.uniform(300))
end
