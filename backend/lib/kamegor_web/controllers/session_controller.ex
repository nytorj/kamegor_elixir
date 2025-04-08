defmodule KamegorWeb.SessionController do
  use KamegorWeb, :controller

  alias Kamegor.Accounts

  # alias KamegorWeb.Auth.Guardian # We'll use Guardian for JWT later if needed, but start with session

  action_fallback(KamegorWeb.FallbackController)

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Accounts.authenticate_user(email, password) do
      %Accounts.User{} = user ->
        # Use Phoenix session for MVP
        conn
        |> put_session(:current_user_id, user.id)
        |> put_status(:ok)
        # Return minimal confirmation, including user_id for context/keychain
        |> render("session.json", %{message: "Login successful", user_id: user.id})

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
    # Use the same view for consistency
    |> render("session.json", %{message: "Logout successful"})
  end

  # Define the view for session responses
  def render("session.json", assigns) do
    # Only include non-nil values in the response map
    assigns
    # Convert assigns map (if it's a struct)
    |> Map.from_struct()
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
