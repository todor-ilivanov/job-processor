alias JobProcessor.TaskManager, as: TaskManager
alias JobProcessor.MyTask, as: MyTask

defmodule JobProcessor do
  @type task :: %{command: String.t(), name: String.t(), requires: list(String.t())}
  @spec process(%{tasks: [task()]}) :: list
  def process(tasks) do
    {:ok, manager_pid} = TaskManager.start_link()
    create_tasks(manager_pid, tasks)

    # todo - return proper result
    tasks |> Enum.map(fn task -> %{name: task["name"], command: task["command"]} end)
  end

  def create_tasks(manager_pid, []), do: send(manager_pid, {:init_complete})

  def create_tasks(manager_pid, [head | tail]) do
    MyTask.new(manager_pid, head)
    create_tasks(manager_pid, tail)
  end
end
