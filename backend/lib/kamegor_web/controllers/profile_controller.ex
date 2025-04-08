<![CDATA[defmodule KamegorWeb.ProfileController do
  use KamegorWeb, :controller

  alias Kamegor.Accounts
  alias Kamegor.Accounts.Profile

  action_fallback KamegorWeb.FallbackController

  def update_seller(conn, %{"profile" => seller_params}) do
    user_id = get_session(conn, :current_user_id)

    if user_id do
      user = Accounts.get_user_by_email(user_id)
      profile = user.profile

      case Accounts.update_profile_seller(profile, seller_params) do
        {:ok, updated_profile} ->
          conn
          |> put_status(:ok)
          |> render(KamegorWeb.ProfileJSON, "profile.json", profile: updated_profile)

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> put_view(json: KamegorWeb.ChangesetJSON)
          |> render(:error, changeset: changeset)
      end
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(json: KamegorWeb.ErrorJSON)
      |> render(:"401", message: "Unauthorized")
    end
  end

  def update_location(conn, %{"latitude" => lat_str, "longitude" => lon_str}) do
    user_id = get_session(conn, :current_user_id)

    with {:ok, lat} <- parse_float(lat_str),
         {:ok, lon} <- parse_float(lon_str),
         user when not is_nil(user) <- Accounts.get_user_by_email(user_id),
         profile when not is_nil(profile) <- user.profile do

      point = %Geo.Point{coordinates: {lon, lat}, srid: 4326}

      changeset = Profile.location_changeset(profile, %{latitude: lat, longitude: lon})

      case Accounts.Repo.update(changeset) do
        {:ok, updated_profile} ->
          conn
          |> put_status(:ok)
          |> render(KamegorWeb.ProfileJSON, "profile.json", profile: updated_profile)

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> put_view(json: KamegorWeb.ChangesetJSON)
          |> render(:error, changeset: changeset)
      end
    else
      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid parameters or user not found"})
    end
  end

  def update_location(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing latitude or longitude"})
  end

  defp parse_float(str) do
    case Float.parse(str) do
      {float, _} -> {:ok, float}
      _ -> {:error, :invalid_float}
    end
  end
end
]]>
