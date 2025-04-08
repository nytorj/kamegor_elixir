defmodule KamegorWeb.UserJSON do
  # alias Kamegor.Accounts.User # Alias might be unused now

  @doc """
  Renders a single user, excluding sensitive fields.
  Handles potential error tuple passed incorrectly.
  """
  def render("user.json", %{user: {:error, _changeset} = error_tuple}) do
    # If we somehow receive an error tuple here, return an error structure
    # This is a workaround for the unexpected rendering path
    %{error: "Unexpected error structure received by UserJSON."}
    # Alternatively, delegate to ChangesetJSON:
    # KamegorWeb.ChangesetJSON.render("error.json", %{changeset: elem(error_tuple, 1)})
  end

  def render("user.json", %{user: user}) do
    # Original success path
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
