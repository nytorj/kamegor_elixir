<![CDATA[defmodule KamegorWeb.SessionController do
  use KamegorWeb, :controller

  alias Kamegor.Accounts
  alias KamegorWeb.Auth.Guardian # We'll use Guardian for JWT later if needed, but start with session

  action_fallback KamegorWeb.FallbackController

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Accounts.authenticate_user(email, password) do
      %Accounts.User{} = user ->
        # Use Phoenix session for MVP
        conn
        |> put_session(:current_user_id, user.id)
        |> put_status(:ok)
        |> render("session.json", %{message: "Login successful", user_id: user.id}) # Return minimal confirmation

      nil ->
        conn
        |> put_status(:unauthorized)
        |> put_view(json: KamegorWeb.ErrorJSON)
        |> render(:"401", message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> put_status(:ok)
    |> render("session.json", %{message: "Logout successful"})
  end
end
]]>
