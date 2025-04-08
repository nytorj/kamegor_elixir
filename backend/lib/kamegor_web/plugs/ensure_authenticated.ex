defmodule KamegorWeb.Plugs.EnsureAuthenticated do
  import Plug.Conn
  # Import redirect/halt correctly
  import Phoenix.Controller, only: [redirect: 2, halt: 1]

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :current_user_id)

    if user_id do
      # Optionally fetch user and assign to conn if needed downstream
      # user = Kamegor.Accounts.get_user_by_id(user_id)
      # assign(conn, :current_user, user)
      conn
    else
      conn
      # Send 401 status
      |> put_status(:unauthorized)
      # Use ErrorJSON view
      |> put_view(json: KamegorWeb.ErrorJSON)
      # Render error message
      |> render(:"401", message: "Unauthorized")
      # Halt the connection
      |> halt()
    end
  end
end
