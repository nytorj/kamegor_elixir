<![CDATA[defmodule KamegorWeb.MapController do
  use KamegorWeb, :controller

  alias Kamegor.Accounts
  alias Geo.Point
  alias KamegorWeb.MapJSON # Will create this view later

  def sellers(conn, %{"lat" => lat_str, "lon" => lon_str, "radius" => radius_str}) do
    with {:ok, lat} <- parse_float(lat_str),
         {:ok, lon} <- parse_float(lon_str),
         {:ok, radius} <- parse_float(radius_str) do

      # Create a Geo.Point from lat/lon
      user_location = %Point{coordinates: {lon, lat}, srid: 4326} # WGS84

      # Fetch sellers within radius from Accounts context - TODO: Implement this function
      sellers = Accounts.list_sellers_in_viewport(user_location, radius) # Assuming radius is in meters

      conn
      |> render(MapJSON, "sellers.json", sellers: sellers) # TODO: Create MapJSON view

    else
      # Handle invalid parameters - return error
      conn
      |> send_resp(:bad_request, "Invalid latitude, longitude, or radius")
    end
  end

  def sellers(conn, _params) do
    # Handle missing parameters - return error
    conn
    |> send_resp(:bad_request, "Latitude, longitude, and radius parameters are required")
  end


  defp parse_float(str) do
    case Float.parse(str) do
      {float, _} -> {:ok, float}
      _ -> {:error, :invalid_float}
    end
  end
end
]]>
