<![CDATA[defmodule KamegorWeb.PresenceChannel do
  use Phoenix.Channel
  alias Phoenix.Presence

  @topic "presence" # Define a topic for presence events

  def join(topic, params, socket) do
    # For MVP, assuming user_id is passed in params for simplicity
    if user_id = params["user_id"] do
      # In real app, authenticate user properly here (e.g., token auth)
      # Fetch user (and profile if needed) - for now just user_id
      # user = Accounts.get_user!(user_id)

      {:ok, assign(socket, :user_id, user_id)} # Assign user_id to socket assigns
    else
      {:error, :unauthorized} # Reject join if no user_id
    end
  end

  def handle_in("ping", _payload, socket) do
    push(socket, "pong", :ok)
    {:noreply, socket}
  end

  # on join, track connected user
  def handle_info(:after_join, socket) do
    user_id = socket.assigns.user_id # Assuming you have user_id in socket assigns after authentication
    device_id = socket.id # Or generate a unique device ID

    Presence.track(socket,
      list: @topic,
      key: user_id, # Use user_id as presence key
      metas: %{status: "online", device_id: device_id, ts: DateTime.utc_now()} # Initial presence metadata
    )

    push(socket, "presence_diff", Presence.list(@topic)) # Send initial presence list to joining user

    {:noreply, socket}
  end

  # on component unmount / channel close, untrack user
  def handle_info(:before_leave, socket) do
    user_id = socket.assigns.user_id # Assuming you have user_id in socket assigns
    Presence.untrack(socket,
      list: @topic,
      key: user_id
    )
    {:noreply, socket}
  end


  # Client-originated presence update (e.g. status change) - if needed later
  # def handle_in("update_status", %{"status" => new_status}, socket) do
  #   user_id = socket.assigns.user_id
  #   Presence.update_meta(socket,
  #     list: @topic,
  #     key: user_id,
  #     metas: %{status: new_status, ts: DateTime.utc_now()}
  #   )
  #   {:noreply, socket}
  # end

  # Presence notifications (broadcast to channel subscribers)
  def handle_info(%Presence.Diff{event: event, presence: presence}, socket) do
    push(socket, "presence_diff", %{event: event, presence: presence})
    {:noreply, socket}
  end

  # Define handle_event for presence events if needed (e.g. to persist status changes)
  # def handle_event("join", _payload, socket) do
  #   # Handle join event, e.g., update user's presence_status in DB to "online"
  #   {:noreply, socket}
  # end
  # def handle_event("leave", _payload, socket) do
  #   # Handle leave event, e.g., update presence_status to "offline"
  #   {:noreply, socket}
  # end
  # def handle_event("presence_state", _payload, socket) do # Initial state
  #   {:noreply, socket}
  # end
  # def handle_event("presence_diff", _payload, socket) do # Updates
  #   {:noreply, socket}
  # end

end
]]>
