defmodule Kamegor.Repo.Migrations.CreateProfilesTable do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :username, :string, null: false
      add :description, :text
      add :is_seller, :boolean, default: false, null: false
      add :rating_avg, :float, default: 0.0, null: false
      add :presence_status, :string, default: "offline", null: false
      # Note: PostGIS geometry type. Ensure PostGIS extension is enabled.
      add :location_geom, :geometry

      timestamps()
    end

    create unique_index(:profiles, [:user_id])
    create unique_index(:profiles, [:username])
    # Create a spatial index for location queries
    execute("CREATE INDEX profiles_location_geom_index ON profiles USING GIST (location_geom);")


  end
end
