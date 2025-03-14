defmodule Commander.JobProcessor.Sorter do
  @moduledoc """
  Serves for sorting Tasks in topological order based on their dependencies.
  """

  alias Commander.JobProcessor.Task

  @type task_name :: String.t()
  @type reason ::
          {:invalid_dependency, task_name()}
          | {:self_dependency, task_name()}
          | {:cycle_detected, [task_name()]}

  @spec sort_tasks([Task.t()]) :: {:ok, [Task.t()]} | {:error, reason()}
  def sort_tasks(tasks) do
    with {:ok, graph} <- build_graph(tasks),
         {:ok, sorted_task_names} <- topological_sort(graph) do
      {:ok, get_sorted_tasks(sorted_task_names, tasks)}
    end
  end

  defp build_graph(tasks) do
    graph = :digraph.new([:acyclic])

    Enum.each(tasks, fn %Task{name: task_name} -> :digraph.add_vertex(graph, task_name) end)

    Enum.reduce_while(tasks, :ok, fn %Task{name: task_name, dependencies: dependencies}, _acc ->
      dependencies
      |> Enum.reduce_while(:ok, fn dep, _acc ->
        id = "#{dep}:#{task_name}"

        case :digraph.add_edge(graph, id, dep, task_name, []) do
          "" <> _ -> {:cont, :ok}
          {:error, {:bad_vertex, ^dep}} -> {:halt, {:error, {:invalid_dependency, dep}}}
          {:error, {:bad_edge, [e, e]}} -> {:halt, {:error, {:self_dependency, task_name}}}
          {:error, {:bad_edge, cycle}} -> {:halt, {:error, {:cycle_detected, cycle}}}
        end
      end)
      |> case do
        :ok -> {:cont, {:ok, graph}}
        error -> {:halt, error}
      end
    end)
  end

  defp topological_sort(graph) do
    case :digraph_utils.topsort(graph) do
      false -> {:error, :cycle_detected}
      sorted -> {:ok, sorted}
    end
  end

  defp get_sorted_tasks(sorted_names, tasks) do
    Enum.map(sorted_names, fn name ->
      Enum.find(tasks, fn %Task{name: n} -> n == name end)
    end)
  end
end
