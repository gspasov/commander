defmodule Extask.Server do
  use GenServer

  alias Extask.Job
  alias Phoenix.PubSub
  alias Extask.RequestValidator.Job.Task

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(%Task{requires: dependencies} = task) do
    if dependencies == [] do
      run_task()
    else
      Enum.each(dependencies, fn topic -> PubSub.subscribe(Extask.PubSub, topic) end)
    end

    {:ok, task}
  end

  @impl true
  def handle_info({:done, dependency, _result}, %Task{requires: dependencies} = task) do
    PubSub.unsubscribe(Extask.PubSub, dependency)

    leftover_dependencies = dependencies -- [dependency]

    if leftover_dependencies == [] do
      run_task()
    end

    {:noreply, %Task{task | requires: leftover_dependencies}}
  end

  @impl true
  def handle_info(:execute, %Task{name: name} = task) do
    :ok = PubSub.broadcast(Extask.PubSub, name, {:done, name, Job.cmd(task)})

    {:stop, :normal, task}
  end

  defp run_task, do: send(self(), :execute)
end
