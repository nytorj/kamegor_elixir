defmodule KamegorWeb.PresenceChannel do
  use Phoenix.Channel
  alias Phoenix.Presence
  # Added
  alias Kamegor.Accounts
  # Added
  alias KamegorWeb.Endpoint

  # Define a topic for presence events
  @topic "presence"
  # Topic for general map updates
  @broadcast_topic "map_updates"

  def join(topic, params, socket) do
    # For MVP, assuming user_id is passed in params for simplicity
    if user_id = params["user_id"] do
      # In real app, authenticate user properly here (e.g., token auth)
      # Fetch user and profile
      # Assuming get_user_by_id exists and preloads profile
      case Accounts.get_user_by_id(user_id) do
        %Accounts.User{profile: %Accounts.Profile{}} = user ->
          # Assign user struct to socket assigns
          {:ok, assign(socket, user: user)}

        _ ->
          {:error, :user_not_found}
      end
    else
      # Reject join if no user_id
      {:error, :unauthorized}
    end
  end

  def handle_in("ping", _payload, socket) do
    push(socket, "pong", :ok)
    {:noreply, socket}
  end

  # on join, track connected user, update DB status, and broadcast presence
  def handle_info(:after_join, socket) do
    user = socket.assigns.user
    # Or generate a unique device ID
    device_id = socket.id

    # Update DB status to "online"
    Accounts.update_presence_status(user.profile, "online")

    # Track presence
    Presence.track(socket,
      list: @topic,
      # Use user_id as presence key
      key: user.id,
      # Initial presence metadata
      metas: %{status: "online", device_id: device_id, ts: DateTime.utc_now()}
    )

    # Broadcast presence update to map clients
    broadcast_presence_update(user, "online")

    # Send initial presence list to joining user
    push(socket, "presence_diff", Presence.list(@topic))

    {:noreply, socket}
  end

  # on component unmount / channel close, untrack user, update DB status, and broadcast presence
  def handle_info(:before_leave, socket) do
    user = socket.assigns.user

    # Update DB status to "offline"
    Accounts.update_presence_status(user.profile, "offline")

    # Untrack presence
    Presence.untrack(socket,
      list: @topic,
      key: user.id
    )

    # Broadcast presence update to map clients
    broadcast_presence_update(user, "offline")

    {:noreply, socket}
  end

  # Client-originated presence update (e.g. status change) - if needed later
  # def handle_in("update_status", %{"status" => new_status}, socket) do
  #   user = socket.assigns.user
  #   # Update DB status
  #   Accounts.update_presence_status(user.profile, new_status)
  #   Presence.update_meta(socket,
  #     list: @topic,
  #     key: user.id,
  #     metas: %{status: new_status, ts: DateTime.utc_now()}
  #   )
  #   # Broadcast presence update to map clients
  #   broadcast_presence_update(user, new_status)
  #   {:noreply, socket}
  # end

  # Presence notifications (broadcast to channel subscribers)
  def handle_info(%Presence.Diff{event: event, presence: presence}, socket) do
    push(socket, "presence_diff", %{event: event, presence: presence})
    {:noreply, socket}
  end

  # Ignore other messages
  def handle_info(_msg, socket), do: {:noreply, socket}

  # --- Helper Functions ---

  defp broadcast_presence_update(%Accounts.User{profile: %Accounts.Profile{} = profile}, status) do
    # Only broadcast if the user is a seller
    if profile.is_seller do
      payload = %{
        event: "presence_update",
        # Construct payload similar to MapJSON
        seller: %{
          id: profile.id,
          user_id: profile.user_id,
          username: profile.username,
          rating_avg: profile.rating_avg,
          # Use the new status
          presence_status: status,
          # Reuse formatter
          location: KamegorWeb.MapJSON.format_location(profile.location_geom)
        }
      }

      Endpoint.broadcast(@broadcast_topic, "presence_update", payload)
    end
  end

  # Handle case where profile might be nil (shouldn't happen if fetched correctly on join)
  defp broadcast_presence_update(_, _), do: nil
end
