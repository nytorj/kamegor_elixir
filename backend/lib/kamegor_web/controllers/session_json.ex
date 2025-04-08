defmodule KamegorWeb.SessionJSON do
  @doc """
  Renders session-related responses (login success, logout success).
  Selects only the expected keys from assigns.
  """
  def render("session.json", assigns) do
    # Explicitly select the keys we want in the JSON response
    Map.take(assigns, [:message, :user_id])
  end
end
