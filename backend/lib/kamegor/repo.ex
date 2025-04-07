defmodule Kamegor.Repo do
  use Ecto.Repo,
    otp_app: :kamegor,
    adapter: Ecto.Adapters.Postgres
end
