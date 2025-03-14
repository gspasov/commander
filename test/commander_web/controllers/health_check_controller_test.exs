defmodule CommanderWeb.HealthCheckControllerTest do
  use CommanderWeb.ConnCase, async: true

  test "health check returns 'ok' when called", %{conn: conn} do
    response =
      conn
      |> get(Routes.health_check_path(conn, :show))
      |> json_response(200)

    assert response == %{"status" => "ok"}
  end
end
