defmodule KamegorWeb.UserController do
  use KamegorWeb, :controller

  alias Kamegor.Accounts
  alias KamegorWeb.UserJSON
  alias KamegorWeb.ChangesetJSON

  action_fallback(KamegorWeb.FallbackController)

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        # Keep standard render for success
        |> render(UserJSON, "user.json", user: user)

      {:error, %Ecto.Changeset{} = changeset} ->
        # Manually render the error JSON using the view, passing assigns as a MAP
        # Pass as map
        error_json = ChangesetJSON.render("error.json", %{changeset: changeset})

        conn
        |> put_status(:unprocessable_entity)
        |> put_resp_content_type("application/json")
        |> send_resp(:unprocessable_entity, Jason.encode!(error_json))
        |> halt()
    end
  end
end
