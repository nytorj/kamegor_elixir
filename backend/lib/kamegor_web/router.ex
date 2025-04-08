defmodule KamegorWeb.Router do
  use KamegorWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    # Fetch session for all API routes
    plug(:fetch_session)
  end

  pipeline :api_auth do
    # plug :fetch_session # No longer needed here, fetched in :api pipeline
    plug(KamegorWeb.Plugs.EnsureAuthenticated)
  end

  # Public API routes (no auth required, but session is fetched)
  scope "/api", KamegorWeb do
    pipe_through(:api)

    post("/users", UserController, :create)
    # Login
    post("/sessions", SessionController, :create)
    # Logout
    delete("/sessions", SessionController, :delete)
  end

  # Authenticated API routes
  scope "/api", KamegorWeb do
    # Apply both pipelines
    pipe_through([:api, :api_auth])

    # Profile routes
    put("/profiles/me/seller", ProfileController, :update_seller)
    post("/location", ProfileController, :update_location)

    # Map routes
    get("/map/sellers", MapController, :sellers)

    # Note: Channels are handled separately in endpoint.ex via UserSocket
  end
end
