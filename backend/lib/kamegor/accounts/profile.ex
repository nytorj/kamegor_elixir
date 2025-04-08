defmodule Kamegor.Accounts.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kamegor.Accounts.User
  alias Kamegor.Repo

  # Define the schema matching the profiles table
  schema "profiles" do
    field(:username, :string)
    field(:description, :text)
    field(:is_seller, :boolean, default: false)
    field(:rating_avg, :float, default: 0.0)
    field(:presence_status, :string, default: "offline")
    # Using PostGIS geometry type
    field(:location_geom, Geo.PostGIS.Geometry)

    # A profile belongs to a user
    belongs_to(:user, User)

    timestamps()
  end

  @doc """
  Builds a changeset for creating/updating a profile.
  """
  def changeset(profile \\ %__MODULE__{}, attrs) do
    profile
    |> cast(attrs, [
      :username,
      :description,
      :is_seller,
      :rating_avg,
      :presence_status,
      :location_geom,
      :user_id
    ])
    |> validate_required([:username, :user_id])
    |> unique_constraint(:username)
    |> unique_constraint(:user_id)
    |> foreign_key_constraint(:user_id)
    # Basic validation for presence status (can be expanded later)
    |> validate_inclusion(:presence_status, ["offline", "online", "streaming"])

    # Add validation for location_geom if needed (e.g., ensure it's a point)
  end

  @doc """
  Changeset specifically for updating seller status and description.
  """
  def seller_changeset(profile, attrs) do
    profile
    |> cast(attrs, [:is_seller, :description])
    |> validate_required([:is_seller])
  end

  @doc """
  Changeset for updating location.
  """
  def location_changeset(profile, attrs) do
    # Expecting attrs like %{latitude: lat, longitude: lon}
    # We need to convert this to a Geo.Point for the location_geom field
    case Map.get(attrs, :latitude), Map.get(attrs, :longitude) do
      {lat, lon} when is_number(lat) and is_number(lon) ->
        # WGS 84
        point = %Geo.Point{coordinates: {lon, lat}, srid: 4326}

        profile
        |> cast(%{location_geom: point}, [:location_geom])

      # Add validation if needed
      _ ->
        # Add an error if lat/lon are missing or invalid
        add_error(
          profile |> cast(attrs, []),
          :location_geom,
          "Invalid latitude/longitude provided"
        )
    end
  end

  @doc """
  Changeset for updating presence status.
  """
  def presence_changeset(profile, attrs) do
    profile
    |> cast(attrs, [:presence_status])
    |> validate_required([:presence_status])
    |> validate_inclusion(:presence_status, ["offline", "online", "streaming"])
  end
end
