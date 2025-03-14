defmodule Commander.JobProcessor do
  @moduledoc """
  Context for holding the main 'business' logic.

  @NOTE/TODO:
  Commander currently does not take into consideration failed cmd commands.
  It will execute all of them independent of previous task failure.
  """

  require Logger

  alias Commander.JobProcessor.Job
  alias Commander.JobProcessor.Task
  alias Commander.JobProcessor.Sorter

  @spec order(Job.t()) :: {:ok, [Task.t()]} | {:error, Sorter.reason()}
  def order(%Job{tasks: tasks}) do
    Sorter.sort_tasks(tasks)
  end

  @spec execute(Job.t()) :: :ok | {:error, Sorter.reason()}
  def execute(%Job{parallel: parallel} = job) do
    with {:ok, sorted_tasks} <- order(job) do
      if parallel do
        sorted_tasks
        |> Enum.reverse()
        |> Enum.each(fn %Task{} = task ->
          {:ok, _pid} = __MODULE__.Server.start_link(task)
        end)
      else
        Enum.each(sorted_tasks, &cmd/1)
      end
    end
  end

  @spec script(Job.t()) :: {:ok, String.t()} | {:error, Sorter.reason()}
  def script(%Job{} = job) do
    with {:ok, sorted_tasks} <- order(job) do
      script =
        sorted_tasks
        |> Enum.map(fn %Task{command: command} -> command end)
        |> List.insert_at(0, "#!/usr/bin/env bash")
        |> Enum.join("\n")

      {:ok, script}
    end
  end

  @spec cmd(Task.t()) :: :ok | :error
  def cmd(%Task{name: name, command: command}) do
    case System.cmd("sh", ["-c", command]) do
      {_response, 0} ->
        Logger.debug("Successfully executed task #{name}")
        :ok

      _ ->
        Logger.error("Error while executing task #{name}")
        :error
    end
  end
end
