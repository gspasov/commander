defmodule ExtaskWeb.Router do
  use ExtaskWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ExtaskWeb do
    pipe_through :api

    post "/tasks/order", TaskController, :order
    post "/tasks/script", TaskController, :script
    post "/tasks/execute", TaskController, :execute
  end
end
