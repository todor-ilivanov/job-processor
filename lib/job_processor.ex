alias JobProcessor.TaskManager, as: TaskManager
alias JobProcessor.MyTask, as: MyTask

defmodule JobProcessor do
  @type task :: %{command: String.t(), name: String.t(), requires: list(String.t())}
  @spec process(%{tasks: [task()]}) :: list
  def process(tasks) do
    {:ok, manager_pid} = TaskManager.start_link()
    create_tasks(manager_pid, tasks)
    send(manager_pid, {:get_all_deps})
    send(manager_pid, {:get_all_tasks})
    tasks |> Enum.map(fn task -> %{name: task["name"], command: task["command"]} end)
  end

  def create_tasks(_manager_pid, []), do: :ok

  def create_tasks(manager_pid, [head | tail]) do
    task_pid = spawn(fn -> MyTask.execute(head) end)
    send(manager_pid, {:put, task_pid, head})
    create_tasks(manager_pid, tail)
  end
end
