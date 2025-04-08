<![CDATA[defmodule KamegorWeb.Plugs.EnsureAuthenticated do
  import Plug.Conn
  alias Phoenix.Controller.Redirect

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :current_user_id)

    if user_id do
      conn
    else
      conn
      |> Redirect.to(path: "/api/unauthorized") # Or wherever you want to redirect on auth failure
      |> halt()
    end
  end
end
]]>
