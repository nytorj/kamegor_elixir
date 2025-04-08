defmodule KamegorWeb.MapController do
  use KamegorWeb, :controller

  alias Kamegor.Accounts
  alias Geo.Point
  # Will create this view later
  alias KamegorWeb.MapJSON

  def sellers(conn, %{"lat" => lat_str, "lon" => lon_str, "radius" => radius_str}) do
    with {:ok, lat} <- parse_float(lat_str),
         {:ok, lon} <- parse_float(lon_str),
         {:ok, radius} <- parse_float(radius_str) do
      # Create a Geo.Point from lat/lon
      # WGS84
      user_location = %Point{coordinates: {lon, lat}, srid: 4326}

      # Fetch sellers within radius from Accounts context
      # Assuming radius is in meters
      sellers = Accounts.list_sellers_in_viewport(user_location, radius)

      conn
      # Use MapJSON view
      |> render(MapJSON, "sellers.json", sellers: sellers)
    else
      # Handle invalid parameters - return error
      # Catch any error from the with statement
      _ ->
        conn
        |> put_status(:bad_request)
        # Use json helper
        |> json(%{error: "Invalid latitude, longitude, or radius"})
    end
  end

  def sellers(conn, _params) do
    # Handle missing parameters - return error
    conn
    |> put_status(:bad_request)
    # Use json helper
    |> json(%{error: "Latitude, longitude, and radius parameters are required"})
  end

  defp parse_float(str) do
    case Float.parse(str) do
      # Ensure the entire string was parsed
      {float, ""} -> {:ok, float}
      _ -> {:error, :invalid_float}
    end
  end
end
