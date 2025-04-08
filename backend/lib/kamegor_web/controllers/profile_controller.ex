defmodule KamegorWeb.ProfileController do
  use KamegorWeb, :controller

  alias Kamegor.Accounts
  alias Kamegor.Accounts.Profile
  # Added for broadcast
  alias KamegorWeb.Endpoint

  action_fallback(KamegorWeb.FallbackController)

  def update_seller(conn, %{"profile" => seller_params}) do
    user_id = get_session(conn, :current_user_id)

    if user_id do
      # Use get_user_by_id which preloads profile
      user = Accounts.get_user_by_id(user_id)

      # Check if user and profile exist
      if user && user.profile do
        profile = user.profile

        case Accounts.update_profile_seller(profile, seller_params) do
          {:ok, updated_profile} ->
            # TODO: Broadcast presence/status change if is_seller toggled?
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
        # Handle case where user or profile not found for the ID in session
        conn
        |> put_status(:not_found)
        |> json(%{error: "User profile not found"})
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
         # Use get_user_by_id which preloads profile
         user when not is_nil(user) <- Accounts.get_user_by_id(user_id),
         profile when not is_nil(profile) <- user.profile do
      # Ensure only sellers can update location
      if profile.is_seller do
        changeset = Profile.location_changeset(profile, %{latitude: lat, longitude: lon})

        case Accounts.Repo.update(changeset) do
          {:ok, updated_profile} ->
            # Broadcast the location update
            broadcast_location_update(updated_profile)

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
        # User is not a seller, forbid location update
        conn
        |> put_status(:forbidden)
        |> json(%{error: "User is not a seller"})
      end
    else
      # Handle parsing errors or user not found
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

  defp broadcast_location_update(%Profile{} = profile) do
    # For MVP, broadcast to a general topic. Clients/MapChannel can filter later.
    # Ideally, broadcast only to relevant viewport topics.
    payload = %{
      event: "location_update",
      # Reuse MapJSON rendering, ensure it handles a single profile
      seller: KamegorWeb.MapJSON.render("sellers.json", sellers: [profile]).data |> List.first()
    }

    Endpoint.broadcast("map_updates", "location_update", payload)
  end
end
