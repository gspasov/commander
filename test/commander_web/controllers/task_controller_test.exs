defmodule CommanderWeb.TaskControllerTest do
  use CommanderWeb.ConnCase, async: true

  setup do
    tasks = [
      %{name: "task-3", command: "cat /tmp/file1", dependencies: ["task-2"]},
      %{name: "task-2", command: "echo 'Hello World' > /tmp/file1", dependencies: ["task-1"]},
      %{name: "task-1", command: "touch /tmp/file1"}
    ]

    %{tasks: tasks}
  end

  test "can correctly order tasks", %{conn: conn, tasks: tasks} do
    params = %{tasks: tasks}

    response =
      conn
      |> post(Routes.task_path(conn, :order), params)
      |> json_response(200)

    assert response == %{
             "status" => "success",
             "data" => %{
               "tasks" => [
                 %{"command" => "touch /tmp/file1", "dependencies" => [], "name" => "task-1"},
                 %{
                   "command" => "echo 'Hello World' > /tmp/file1",
                   "dependencies" => ["task-1"],
                   "name" => "task-2"
                 },
                 %{
                   "command" => "cat /tmp/file1",
                   "dependencies" => ["task-2"],
                   "name" => "task-3"
                 }
               ]
             }
           }
  end

  test "successfully executes tasks sequentially", %{conn: conn, tasks: tasks} do
    params = %{tasks: tasks}

    response =
      conn
      |> post(Routes.task_path(conn, :execute), params)
      |> text_response(200)

    assert response == ""
  end

  test "successfully executes tasks in parallel", %{conn: conn, tasks: tasks} do
    params = %{parallel: true, tasks: tasks}

    response =
      conn
      |> post(Routes.task_path(conn, :execute), params)
      |> text_response(200)

    assert response == ""
  end

  test "successfully returns a bash script based on the given tasks", %{conn: conn, tasks: tasks} do
    params = %{tasks: tasks}

    response =
      conn
      |> post(Routes.task_path(conn, :script), params)
      |> text_response(200)

    assert response ==
             "#!/usr/bin/env bash\ntouch /tmp/file1\necho 'Hello World' > /tmp/file1\ncat /tmp/file1"
  end

  describe "return 422 when request validation fails" do
    for action <- [:order, :execute, :script] do
      test action, %{conn: conn} do
        params = %{tasks: [%{command: "cat /tmp/file1"}]}

        response =
          conn
          |> post(Routes.task_path(conn, unquote(action)), params)
          |> json_response(422)

        assert response == %{
                 "status" => "error",
                 "error_code" => "VALIDATION_FAILED",
                 "message" => "Input validation failed.",
                 "details" => %{"tasks" => [%{"name" => ["can't be blank"]}]}
               }
      end
    end
  end

  describe "returns 400 when there is a cyclic dependency" do
    for action <- [:order, :execute, :script] do
      test action, %{conn: conn} do
        params = %{
          tasks: [
            %{name: "task-1", command: "touch /tmp/file1"},
            %{
              name: "task-2",
              command: "echo 'Hello World' > /tmp/file1",
              dependencies: ["task-3"]
            },
            %{name: "task-3", command: "cat /tmp/file1", dependencies: ["task-2"]}
          ]
        }

        response =
          conn
          |> post(Routes.task_path(conn, unquote(action)), params)
          |> json_response(400)

        assert response == %{
                 "status" => "error",
                 "error_code" => "DEPENDENCY_CYCLE",
                 "message" => "A cycle dependency was detected.",
                 "details" => %{"cycle" => ["task-3", "task-2"]}
               }
      end
    end
  end

  describe "returns 400 when there is a missing/invalid dependency" do
    for action <- [:order, :execute, :script] do
      test action, %{conn: conn} do
        params = %{
          tasks: [
            %{name: "task-1", command: "touch /tmp/file1"},
            %{
              name: "task-2",
              command: "echo 'Hello World' > /tmp/file1",
              dependencies: ["task-4"]
            },
            %{name: "task-3", command: "cat /tmp/file1", dependencies: ["task-2"]}
          ]
        }

        response =
          conn
          |> post(Routes.task_path(conn, unquote(action)), params)
          |> json_response(400)

        assert response == %{
                 "status" => "error",
                 "error_code" => "INVALID_DEPENDENCY",
                 "details" => %{"missing_dependency" => "task-4"},
                 "message" => "One or more tasks have dependency that does not exist."
               }
      end
    end
  end
end
