defmodule JobProcessor.MyTask do
  @enforce_keys [:name, :command]
  defstruct [:name, :command, :unfinished_parents]

  alias JobProcessor.MyTask, as: MyTask

  def new(manager_pid, task) do
    unfinished_parents = if task["requires"] == nil, do: [], else: task["requires"]

    new_task = %MyTask{
      name: task["name"],
      command: task["command"],
      unfinished_parents: unfinished_parents
    }

    {:ok, pid} = Task.start_link(fn -> loop(manager_pid, new_task) end)
    send(manager_pid, {:put, pid, new_task})
  end

  defp loop(manager_pid, task) do
    receive do
      {:parent_finished, parent_name} ->
        new_unfinished_parents = List.delete(task.unfinished_parents, parent_name)
        new_task = %MyTask{task | unfinished_parents: new_unfinished_parents}
        execute(manager_pid, new_task)
        loop(manager_pid, new_task)

      {:execute} ->
        execute(manager_pid, task)
        loop(manager_pid, task)

      {:stop} ->
        :stopped
    end
  end

  defp execute(manager_pid, task) when length(task.unfinished_parents) == 0 do
    send(manager_pid, {:task_finished, task})
    send(self(), {:stop})
  end

  defp execute(_manager_pid, _task), do: :waiting
end
