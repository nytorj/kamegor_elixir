defmodule KamegorWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :kamegor,
    # Use the PubSub server defined in application.ex
    pubsub_server: Kamegor.PubSub
end
