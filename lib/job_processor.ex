alias JobProcessor.TaskManager, as: TaskManager

defmodule JobProcessor do
  @type task :: %{command: String.t(), name: String.t(), requires: list(String.t())}
  @spec process(%{tasks: [task()]}) :: list
  def process(tasks) do
    {:ok, manager_pid} = TaskManager.start_link()
    create_tasks(manager_pid, tasks)
    tasks |> Enum.map(fn task -> %{name: task["name"], command: task["command"]} end)
  end

  def create_tasks(_manager_pid, []), do: :ok

  def create_tasks(manager_pid, tasks) do
    [head | tail] = tasks
    task_pid = spawn(fn -> do_task(head) end)
    send(manager_pid, {:put, task_pid, head})
    create_tasks(manager_pid, tail)
  end

  def do_task(task) do
    IO.inspect(task["name"])
  end
end
