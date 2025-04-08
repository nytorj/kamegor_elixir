defmodule KamegorWeb.Plugs.EnsureAuthenticated do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :current_user_id)

    if user_id do
      # User is authenticated, pass the connection along
      # Optionally assign user if needed: assign(conn, :current_user, Accounts.get_user_by_id(user_id))
      conn
    else
      # User is not authenticated, send 401 and halt
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:unauthorized, Jason.encode!(%{error: "Unauthorized"}))
      |> halt()
    end
  end
end
