defmodule CommanderWeb.HealthCheckController do
  use CommanderWeb, :controller

  def show(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
