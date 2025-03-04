defmodule Extask.Job do
  alias Extask.Server
  alias Extask.RequestValidator.Job
  alias Extask.RequestValidator.Job.Task

  require Logger

  @spec order(Job.t()) ::
          {:error, :cycle_detected | {:invalid_dependency, binary()}}
          | {:ok, [Extask.RequestValidator.Job.Task.t()]}
  def order(%Job{tasks: tasks}) do
    with :ok <- validate_dependencies(tasks) do
      sort(tasks)
    end
  end

  @spec execute(Job.t()) :: :ok | {:error, :cycle_detected | {:invalid_dependency, String.t()}}
  def execute(%Job{parallel: parallel} = job) do
    with {:ok, sorted_tasks} <- order(job) do
      if parallel do
        sorted_tasks
        |> Enum.reverse()
        |> Enum.each(fn %Task{} = task ->
          {:ok, _pid} = Server.start_link(task)
        end)
      else
        Enum.each(sorted_tasks, &cmd/1)
      end
    end
  end

  @spec script(Job.t()) ::
          :ok | {:error, :cycle_detected | {:invalid_dependency, String.t()}}
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

  @spec validate_dependencies([Task.t()]) :: :ok | {:error, {:invalid_dependency, String.t()}}
  def validate_dependencies(tasks) do
    valid_dependencies = Enum.map(tasks, & &1.name)

    Enum.reduce_while(tasks, :ok, fn
      %Task{requires: dependencies}, acc ->
        dependencies
        |> Enum.reduce_while(:ok, fn d, acc ->
          if d in valid_dependencies do
            {:cont, acc}
          else
            {:halt, d}
          end
        end)
        |> case do
          :ok -> {:cont, acc}
          d -> {:halt, {:error, {:invalid_dependency, d}}}
        end
    end)
  end

  @spec sort([Task.t()]) :: {:ok, [Task.t()]} | {:error, :cycle_detected}
  def sort(tasks) do
    tasks
    |> Enum.map(fn %Task{requires: dependencies} = task -> {task, dependencies} end)
    |> do_sort(length(tasks), [])
  end

  defp do_sort([], _attempts, acc), do: {:ok, Enum.reverse(acc)}

  defp do_sort([{%Task{name: name} = task, []} | rest], _attempts, acc) do
    rest =
      Enum.map(rest, fn {%Task{} = t, dependencies} ->
        {t, dependencies -- [name]}
      end)

    do_sort(rest, length(rest), [task | acc])
  end

  defp do_sort(_tasks, attempts, _acc) when attempts == 0 do
    {:error, :cycle_detected}
  end

  defp do_sort([{%Task{}, _deps} = task | rest], attempts, acc) do
    do_sort(rest ++ [task], attempts - 1, acc)
  end
end
