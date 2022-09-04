alias JobProcessor.TaskManager, as: TaskManager

defmodule JobProcessor do
  @type task :: %{command: String.t(), name: String.t(), requires: list(String.t())}
  @spec process(%{tasks: [task()]}) :: list
  def process(tasks) do
    {:ok, manager_pid} = TaskManager.start_link()
    send(manager_pid, {:create_tasks, tasks})

    # todo - return proper result
    tasks |> Enum.map(fn task -> %{name: task["name"], command: task["command"]} end)
  end
end
