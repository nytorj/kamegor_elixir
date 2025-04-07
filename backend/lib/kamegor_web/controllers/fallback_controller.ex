<![CDATA[defmodule KamegorWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use KamegorWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete functions
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: KamegorWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is invoked when the controller action doesn't match
  # (e.g., resource not found in show/update/delete actions)
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
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
end
]]>
