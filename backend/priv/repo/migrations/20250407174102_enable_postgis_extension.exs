defmodule Kamegor.Repo.Migrations.EnablePostgisExtension do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS postgis;")


  end
end
