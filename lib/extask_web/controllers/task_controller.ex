defmodule ExtaskWeb.TaskController do
  use ExtaskWeb, :controller

  alias Extask.Job
  alias Extask.Utils
  alias Extask.RequestValidator

  def order(conn, params) do
    with {:ok, %RequestValidator.Job{} = job} <-
           params
           |> RequestValidator.validate(&RequestValidator.Job.changeset/1)
           |> Utils.tag(:changeset),
         {:ok, sorted_tasks} <- job |> Job.order() |> Utils.tag(:job) do
      conn
      |> put_status(200)
      |> json(sorted_tasks)
    else
      error -> handle_error(conn, error)
    end
  end

  def script(conn, params) do
    with {:ok, %RequestValidator.Job{} = job} <-
           params
           |> RequestValidator.validate(&RequestValidator.Job.changeset/1)
           |> Utils.tag(:changeset),
         {:ok, script} <- job |> Job.script() |> Utils.tag(:job) do
      conn
      |> put_status(200)
      |> text(script)
    else
      error -> handle_error(conn, error)
    end
  end

  def execute(conn, params) do
    with {:ok, %RequestValidator.Job{} = job} <-
           params
           |> RequestValidator.validate(&RequestValidator.Job.changeset/1)
           |> Utils.tag(:changeset),
         :ok <- job |> Job.execute() |> Utils.tag(:job) do
      conn
      |> put_status(200)
      |> Phoenix.Controller.text("")
    else
      error -> handle_error(conn, error)
    end
  end

  defp handle_error(conn, {:changeset, {:error, changeset_errors}}) do
    conn
    |> put_status(400)
    |> json(%{message: "Validation failed", errors: changeset_errors})
  end

  defp handle_error(conn, {:job, {:error, :cycle_detected}}) do
    conn
    |> put_status(400)
    |> json(%{message: "Cycle dependency detected."})
  end

  defp handle_error(conn, {:job, {:error, {:invalid_dependency, dependency}}}) do
    conn
    |> put_status(400)
    |> json(%{message: "Invalid dependency", error: %{invalid_dependency: dependency}})
  end
end
