defmodule MyTask do
  @enforce_keys [:name, :command]
  defstruct [:name, :command, :unfinished_parents]
end

defmodule JobProcessor.TaskManager do
  def start_link do
    Task.start_link(fn -> loop(%{}, %{}) end)
  end

  defp loop(pid_map, dep_map) do
    receive do
      {:get, pid, caller} ->
        send(caller, Map.get(pid_map, pid))
        loop(pid_map, dep_map)

      {:put, pid, value} ->
        task = new_task(value)
        new_dep_map = update_dep_map(dep_map, task.name, task.unfinished_parents)
        loop(Map.put(pid_map, task.name, pid), new_dep_map)

      {:task_finished, task} ->
        finished_task = new_task(value)
        notify_children(finished_task, dep_map)
        loop(pid_map, dep_map)

      {:get_all_deps} ->
        IO.inspect(dep_map)
        loop(pid_map, dep_map)

      {:get_all_tasks} ->
        IO.inspect(pid_map)
        loop(pid_map, dep_map)
    end
  end

  defp update_dep_map(dep_map, _child_name, nil), do: dep_map
  defp update_dep_map(dep_map, _child_name, []), do: dep_map

  defp update_dep_map(dep_map, child_name, [head | tail]) do
    {_old_value, new_dep_map} =
      Map.get_and_update(dep_map, head, fn current_value ->
        {current_value, [child_name | current_value]}
      end)

    update_dep_map(new_dep_map, child_name, tail)
  end

  defp notify_children(task, dep_map) do
    children = dep_map[task]
    # todo - send to all children..
  end

  defp new_task(task) do
    unfinished_parents = if task["requires"] == nil, do: [], else: task["requires"]
    %MyTask{name: task["name"], command: task["command"], unfinished_parents: unfinished_parents}
  end
end
