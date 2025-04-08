defmodule KamegorWeb.MapChannel do
  use KamegorWeb, :channel
  alias Kamegor.Accounts
  # Reuse the MapJSON view
  alias KamegorWeb.MapJSON
  # Added for broadcast subscription
  alias KamegorWeb.Endpoint

  # Topic format: "map:lat,lon,radius"
  @topic_prefix "map:"
  # Topic for general updates
  @broadcast_topic "map_updates"

  def join(topic, _params, socket) do
    # Check topic prefix inside the function body
    if topic |> String.starts_with?(@topic_prefix) do
      # TODO: Authenticate user if needed for map viewing

      # Parse viewport from topic
      case parse_viewport_topic(topic) do
        {:ok, viewport} ->
          # Subscribe to general map updates
          Endpoint.subscribe(@broadcast_topic)

          # Fetch initial sellers for the viewport
          sellers = Accounts.list_sellers_in_viewport(viewport.center, viewport.radius)

          # Send initial list to the joining client
          push(socket, "sellers_list", MapJSON.render("sellers.json", sellers: sellers))

          # Store viewport in assigns for filtering broadcasts
          socket = assign(socket, :viewport, viewport)

          {:ok, socket}

        {:error, _reason} ->
          {:error, %{reason: "invalid_viewport_topic"}}
      end
    else
      # Topic doesn't match the expected prefix
      {:error, %{reason: "invalid_topic"}}
    end
  end

  # Handle incoming messages if needed (e.g., client updating their viewport)
  # def handle_in("update_viewport", %{"lat" => lat, "lon" => lon, "radius" => radius}, socket) do
  #   # Potentially leave old topic, join new one
  #   {:noreply, socket}
  # end

  # Handle broadcasts from Endpoint
  def handle_info(
        %{topic: @broadcast_topic, event: "location_update", payload: %{seller: seller_data}},
        socket
      ) do
    # Check if the updated seller is within the client's viewport
    if is_seller_in_viewport?(seller_data, socket.assigns.viewport) do
      # Push the update to the client
      push(socket, "seller_update", seller_data)
    end

    {:noreply, socket}
  end

  # Handle presence update broadcasts
  def handle_info(
        %{topic: @broadcast_topic, event: "presence_update", payload: %{seller: seller_data}},
        socket
      ) do
    # Check if the updated seller is within the client's viewport
    # Note: We might push even if they move *out* of viewport if status is offline
    if is_seller_in_viewport?(seller_data, socket.assigns.viewport) or
         seller_data.presence_status == "offline" do
      # Push the update to the client
      push(socket, "seller_update", seller_data)
    end

    {:noreply, socket}
  end

  # Handle other broadcast events (e.g., presence changes) later
  # Ignore other messages
  def handle_info(_msg, socket), do: {:noreply, socket}

  # --- Helper Functions ---

  defp parse_viewport_topic(topic) do
    topic
    |> String.trim_leading(@topic_prefix)
    |> String.split(",")
    |> case do
      [lat_str, lon_str, radius_str] ->
        with {:ok, lat} <- parse_float(lat_str),
             {:ok, lon} <- parse_float(lon_str),
             {:ok, radius} <- parse_float(radius_str) do
          center = %Geo.Point{coordinates: {lon, lat}, srid: 4326}
          {:ok, %{center: center, radius: radius}}
        else
          _ -> {:error, :invalid_format}
        end

      _ ->
        {:error, :invalid_format}
    end
  end

  defp parse_float(str) do
    case Float.parse(str) do
      # Ensure the entire string was parsed
      {float, ""} -> {:ok, float}
      _ -> {:error, :invalid_float}
    end
  end

  defp is_seller_in_viewport?(seller_data, viewport) do
    # Extract seller location and viewport details
    seller_location_map = seller_data.location
    viewport_center = viewport.center
    # Assuming meters
    viewport_radius = viewport.radius

    if seller_location_map do
      seller_point = %Geo.Point{
        coordinates: {seller_location_map.longitude, seller_location_map.latitude},
        srid: 4326
      }

      # Use Geo.distance to check if seller is within viewport radius
      # Note: Geo.distance calculates distance in meters for SRID 4326
      distance = Geo.distance(seller_point, viewport_center)

      distance <= viewport_radius
    else
      # Seller has no location data
      false
    end
  end
end
