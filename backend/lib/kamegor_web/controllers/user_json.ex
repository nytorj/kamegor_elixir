<![CDATA[defmodule KamegorWeb.UserJSON do
  alias Kamegor.Accounts.User

  @doc """
  Renders a single user, excluding sensitive fields.
  """
  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email
      # Add other fields to return as needed, e.g., from preloaded profile
      # profile: render_profile(user.profile)
    }
  end

  # Helper function if profile needs rendering
  # defp render_profile(profile) when not is_nil(profile) do
  #   %{
  #     username: profile.username,
  #     description: profile.description,
  #     is_seller: profile.is_seller,
  #     rating_avg: profile.rating_avg,
  #     presence_status: profile.presence_status
  #     # Add location if needed, maybe formatted differently
  #   }
  # end
  # defp render_profile(_), do: nil
end
]]>
