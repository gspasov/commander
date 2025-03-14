defmodule Commander.JobProcessor.Server do
  @moduledoc """
  Server for executing Tasks in parallel.
  Each Task subscribes and listens for the execution of all its dependencies.
  Once all of its dependencies are finished it can run.

  The process exists as soon as the Task is finished.
  """

  use GenServer

  alias Phoenix.PubSub
  alias Commander.JobProcessor
  alias Commander.JobProcessor.Task

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(%Task{dependencies: dependencies} = task) do
    case dependencies do
      [] -> run_task()
      _ -> Enum.each(dependencies, fn topic -> PubSub.subscribe(Commander.PubSub, topic) end)
    end

    {:ok, task}
  end

  @impl true
  def handle_info({:done, dependency, _result}, %Task{dependencies: dependencies} = task) do
    PubSub.unsubscribe(Commander.PubSub, dependency)

    leftover_dependencies = dependencies -- [dependency]

    if leftover_dependencies == [] do
      run_task()
    end

    {:noreply, %Task{task | dependencies: leftover_dependencies}}
  end

  @impl true
  def handle_info(:execute, %Task{name: name} = task) do
    :ok = PubSub.broadcast(Commander.PubSub, name, {:done, name, JobProcessor.cmd(task)})

    {:stop, :normal, task}
  end

  defp run_task, do: send(self(), :execute)
end
