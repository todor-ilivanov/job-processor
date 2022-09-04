alias JobProcessor.TaskManager, as: TaskManager

defmodule JobProcessor do

  def process(nil), do: raise "No tasks provided."

  @type task :: %{command: String.t(), name: String.t(), requires: list(String.t())}
  @spec process(%{tasks: [task()]}) :: list
  def process(tasks) do
    task_manager = TaskManager.async()
    send(task_manager.pid, {:create_tasks, tasks})
    {:ok, ordered_tasks} = Task.await(task_manager)
    ordered_tasks |> Enum.map(fn task -> %{name: task.name, command: task.command} end)
  end
end
