defmodule KamegorWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use KamegorWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete functions
  # It will now be the primary handler for changeset errors if action_fallback is used.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    # Use ChangesetJSON view
    |> put_view(json: KamegorWeb.ChangesetJSON)
    # Use the correct template name
    |> render("error.json", changeset: changeset)
  end

  # This clause is invoked when the controller action doesn't match
  # (e.g., resource not found in show/update/delete actions)
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    # Use ErrorJSON view
    |> put_view(json: KamegorWeb.ErrorJSON)
    |> render(:"404")
  end

  # Add clauses for other errors as needed, e.g., :unauthorized, :forbidden
  # def call(conn, {:error, :unauthorized}) do
  #   conn
  #   |> put_status(:unauthorized)
  #   |> put_view(json: KamegorWeb.ErrorJSON)
  #   |> render(:"401", message: "Unauthorized")
  # end

  # Generic fallback for other {:error, reason} tuples
  def call(conn, {:error, reason}) do
    conn
    # Or appropriate status
    |> put_status(:internal_server_error)
    |> put_view(json: KamegorWeb.ErrorJSON)
    |> render(:"500", message: "Server error: #{inspect(reason)}")
  end
end
