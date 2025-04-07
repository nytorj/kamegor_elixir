<![CDATA[defmodule KamegorWeb.UserController do
  use KamegorWeb, :controller

  alias Kamegor.Accounts
  alias Kamegor.Accounts.User

  action_fallback KamegorWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        # Optionally preload profile if needed in response
        # user = Kamegor.Repo.preload(user, :profile)

        conn
        |> put_status(:created)
        # Consider what user data to return. Avoid sending password_hash.
        |> render("user.json", user: Map.from_struct(user) |> Map.drop([:password_hash, :__meta__, :profile])) # Example: return basic user info

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: KamegorWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  # Add other actions (show, update, delete) as needed
end
]]>
