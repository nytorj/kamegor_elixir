defmodule KamegorWeb.MapJSON do
  alias Kamegor.Accounts.Profile

  @doc """
  Renders a list of sellers for the map.
  """
  def render("sellers.json", %{sellers: sellers}) do
    %{data: for(seller <- sellers, do: render_seller(seller))}
  end

  defp render_seller(%Profile{} = profile) do
    %{
      id: profile.id,
      user_id: profile.user_id,
      username: profile.username,
      # pic_url: profile.pic_url, # TODO: Add pic_url field to Profile schema later
      rating_avg: profile.rating_avg,
      presence_status: profile.presence_status,
      location: format_location(profile.location_geom)
      # Add other necessary fields
    }
  end

  # Helper to format Geo.Point to simple lat/lon map
  defp format_location(%Geo.Point{coordinates: {lon, lat}}) do
    %{latitude: lat, longitude: lon}
  end

  # Handle nil location
  defp format_location(_), do: nil
end
