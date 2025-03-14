defmodule CommanderWeb.Router do
  use CommanderWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/health", CommanderWeb do
    get "/check", HealthCheckController, :show
  end

  scope "/api", CommanderWeb do
    pipe_through :api

    scope "/tasks" do
      post "/order", TaskController, :order
      post "/script", TaskController, :script
      post "/execute", TaskController, :execute
    end
  end
end
