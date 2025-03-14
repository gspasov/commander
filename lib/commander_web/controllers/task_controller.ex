defmodule CommanderWeb.TaskController do
  use CommanderWeb, :controller

  alias Commander.Utils
  alias Commander.JobProcessor
  alias Commander.JobProcessor.Job
  alias Commander.Validator

  require Logger

  def order(conn, params) do
    with {:ok, %Job{} = job} <-
           params
           |> Validator.validate(&Job.changeset/1)
           |> Utils.tag_error(:changeset),
         {:ok, sorted_tasks} <- job |> JobProcessor.order() |> Utils.tag_error(:job) do
      conn
      |> put_status(200)
      |> json(%{status: "success", data: %{tasks: sorted_tasks}})
    else
      error ->
        Logger.error("[#{__MODULE__}] Order tasks failed with: #{inspect(error)}")
        handle_error(conn, error)
    end
  end

  def script(conn, params) do
    with {:ok, %Job{} = job} <-
           params
           |> Validator.validate(&Job.changeset/1)
           |> Utils.tag_error(:changeset),
         {:ok, script} <- job |> JobProcessor.script() |> Utils.tag_error(:job) do
      conn
      |> put_status(200)
      |> text(script)
    else
      error ->
        Logger.error("[#{__MODULE__}] Script tasks failed with: #{inspect(error)}")
        handle_error(conn, error)
    end
  end

  def execute(conn, params) do
    with {:ok, %Job{} = job} <-
           params
           |> Validator.validate(&Job.changeset/1)
           |> Utils.tag_error(:changeset),
         :ok <- job |> JobProcessor.execute() |> Utils.tag_error(:job) do
      conn
      |> put_status(200)
      |> Phoenix.Controller.text("")
    else
      error ->
        Logger.error("[#{__MODULE__}] Execute tasks failed with: #{inspect(error)}")
        handle_error(conn, error)
    end
  end

  defp handle_error(conn, {:changeset, {:error, changeset_errors}}) do
    conn
    |> put_status(422)
    |> json(%{
      status: "error",
      error_code: "VALIDATION_FAILED",
      message: "Input validation failed.",
      details: changeset_errors
    })
  end

  defp handle_error(conn, {:job, {:error, {:cycle_detected, cycle}}}) do
    conn
    |> put_status(400)
    |> json(%{
      status: "error",
      error_code: "DEPENDENCY_CYCLE",
      message: "A cycle dependency was detected.",
      details: %{cycle: cycle}
    })
  end

  defp handle_error(conn, {:job, {:error, {:invalid_dependency, dependency}}}) do
    conn
    |> put_status(400)
    |> json(%{
      status: "error",
      error_code: "INVALID_DEPENDENCY",
      message: "One or more tasks have dependency that does not exist.",
      details: %{missing_dependency: dependency}
    })
  end
end
