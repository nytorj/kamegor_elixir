defmodule KamegorWeb.ProfileJSON do
  alias Kamegor.Accounts.Profile

  @doc """
  Renders a single profile.
  """
  def render("profile.json", %{profile: profile}) do
    %{
      id: profile.id,
      username: profile.username,
      description: profile.description,
      is_seller: profile.is_seller,
      rating_avg: profile.rating_avg,
      presence_status: profile.presence_status,
      user_id: profile.user_id
      # location_geom: profile.location_geom # Decide if location should be exposed in API
    }
  end
end
