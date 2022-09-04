defmodule JobProcessor.TaskManager do
  def start_link do
    Task.start_link(fn -> loop(%{}, %{}) end)
  end

  defp loop(pid_map, dep_map) do
    receive do
      {:put, pid, task} ->
        new_dep_map = update_dep_map(dep_map, task.name, task.unfinished_parents)
        loop(Map.put(pid_map, task.name, pid), new_dep_map)

      {:task_finished, finished_task} ->
        notify_children(pid_map, finished_task, dep_map[finished_task.name])
        loop(pid_map, dep_map)

      {:init_complete} ->
        for pid <- Map.values(pid_map), do: send(pid, {:execute})
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

  defp notify_children(_pid_map, _task, nil), do: :ok
  defp notify_children(_pid_map, _task, []), do: :ok

  defp notify_children(pid_map, task, [head | tail]) do
    child_pid = pid_map[head]
    send(child_pid, {:parent_finished, task.name})
    notify_children(pid_map, task, tail)
  end
end
