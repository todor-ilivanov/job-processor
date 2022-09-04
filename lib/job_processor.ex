defmodule JobProcessor do
  @type task :: %{command: String.t(), name: String.t(), requires: list(String.t())}
  @spec process(%{tasks: [task()]}) :: list
  def process(tasks) do
    create_tasks(tasks)
    tasks |> Enum.map(fn task -> %{name: task["name"], command: task["command"]} end)
  end

  def create_tasks([]), do: :ok

  def create_tasks(tasks) do
    [head | tail] = tasks
    spawn(fn -> do_task(head) end)
    create_tasks(tail)
  end

  def do_task(task) do
    IO.inspect(task["name"])
  end
end
