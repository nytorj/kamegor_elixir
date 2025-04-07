defmodule KamegorWeb.Router do
  use KamegorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", KamegorWeb do
    pipe_through :api
    post "/users", UserController, :create

  end
end
