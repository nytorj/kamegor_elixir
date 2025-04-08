defmodule KamegorWeb.UserSocket do
  use Phoenix.Socket

  # Channels for user presence and map updates
  channel("presence", KamegorWeb.PresenceChannel)
  channel("map:*", KamegorWeb.MapChannel)
  # Add other channels like "stream:", "chat:" later

  # 2 weeks in seconds
  @max_age 2 * 7 * 24 * 60 * 60

  @doc """
  Authenticates the user socket connection.

  Uses the session cookie to identify the user.
  Assigns the user_id to the socket if authenticated.
  """
  def connect(%{"session" => session}, socket, _connect_info) do
    # Use the session to get the user_id
    case get_session(socket, session, :current_user_id) do
      nil ->
        # Reject connection if no user_id in session
        :error

      user_id ->
        # Optionally verify user_id exists in DB
        # if Kamegor.Accounts.get_user_by_id(user_id) do
        #   {:ok, assign(socket, :user_id, user_id)}
        # else
        #   :error
        # end
        # Assign user_id for now
        {:ok, assign(socket, :user_id, user_id)}
    end
  end

  # Fallback if session is missing or invalid
  def connect(_params, _socket, _connect_info), do: :error

  @doc """
  Identifies the socket connection.
  """
  def id(socket), do: "users_socket:#{socket.assigns.user_id}"

  # --- Helper Functions ---

  # Safely get session data from connect_info
  # (Adapted from Phoenix.Token)
  defp get_session(socket, session, key) do
    case Phoenix.Token.verify(socket, "user socket", session, max_age: @max_age) do
      {:ok, user_id_binary} ->
        # Assuming user_id is stored directly as binary in session after login
        # Convert binary ID back to integer if needed, or handle based on how it's stored
        # Adjust if ID is not integer
        String.to_integer(user_id_binary)

      {:error, _reason} ->
        nil
    end
  rescue
    # Handle potential errors during verification/conversion
    _ -> nil
  end
end
