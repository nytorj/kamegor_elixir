<![CDATA[defmodule KamegorWeb.Router do
  use KamegorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser_auth do
    plug KamegorWeb.Plugs.EnsureAuthenticated
  end

  scope "/api", KamegorWeb do
    pipe_through [:browser_auth, :api] # Apply both pipelines

    post "/users", UserController, :create
    put "/profiles/me/seller", ProfileController, :update_seller"
    get "/map/sellers", MapController, :sellers


    channel "/presence", PresenceChannel # Mount PresenceChannel on /api/presence
  end
end
]]>
