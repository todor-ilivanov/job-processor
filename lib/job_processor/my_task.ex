defmodule JobProcessor.MyTask do
  @enforce_keys [:name, :command]
  defstruct [:name, :command, :unfinished_parents]

  alias JobProcessor.MyTask, as: MyTask

  def new(task) do
    unfinished_parents = if task["requires"] == nil, do: [], else: task["requires"]
    %MyTask{name: task["name"], command: task["command"], unfinished_parents: unfinished_parents}
  end

  def execute(_task) do
    # todo receive...
  end
end
