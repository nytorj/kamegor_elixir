defmodule Kamegor.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias Kamegor.Repo

  alias Kamegor.Accounts.User
  alias Kamegor.Accounts.Profile

  @doc """
  Registers a new user with an associated profile.
  """
  def register_user(attrs) do
    # Convert potential string keys from JSON to atom keys
    atom_attrs = Enum.into(attrs, %{}, fn {k, v} -> {String.to_atom(k), v} end)

    # Use atom keys
    profile_attrs = Map.take(atom_attrs, [:username])
    # Use atom keys
    user_attrs = Map.take(atom_attrs, [:email, :password])

    Repo.transaction(fn ->
      case User.changeset(%User{}, user_attrs) do
        %Ecto.Changeset{valid?: true} = user_changeset ->
          case Repo.insert(user_changeset) do
            {:ok, user} ->
              # Add user_id to profile attributes
              profile_attrs_with_user_id = Map.put(profile_attrs, :user_id, user.id)

              case Profile.changeset(%Profile{}, profile_attrs_with_user_id) do
                %Ecto.Changeset{valid?: true} = profile_changeset ->
                  case Repo.insert(profile_changeset) do
                    {:ok, _profile} ->
                      Logger.debug("User and Profile created: ID=#{user.id}, Email=#{user.email}")
                      # Return the created user
                      {:ok, user}

                    {:error, profile_changeset_error} ->
                      Logger.error("Profile insert failed: #{inspect(profile_changeset_error)}")
                      Repo.rollback(profile_changeset_error)
                  end

                %Ecto.Changeset{} = profile_changeset_error ->
                  Logger.error("Profile changeset invalid: #{inspect(profile_changeset_error)}")
                  Repo.rollback(profile_changeset_error)
              end

            {:error, user_changeset_error} ->
              Logger.error("User insert failed: #{inspect(user_changeset_error)}")
              Repo.rollback(user_changeset_error)
          end

        %Ecto.Changeset{} = user_changeset_error ->
          Logger.error("User changeset invalid: #{inspect(user_changeset_error)}")
          {:error, user_changeset_error}
      end
    end)
  end

  @doc """
  Returns the user with the given email.
  Returns nil if no user is found.
  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
    # |> Repo.preload(:profile) # Keep commented out for now
  end

  @doc """
  Returns the user with the given ID, preloading the profile.
  Returns nil if no user is found.
  """
  def get_user_by_id(id) do
    Repo.get(User, id)
    |> Repo.preload(:profile)
  end

  @doc """
  Authenticates a user by email and password.
  Returns the user if authentication is successful, otherwise nil.
  """
  def authenticate_user(email, password) do
    user = get_user_by_email(email)
    Logger.debug("Authenticating user: #{inspect(email)}. Found user: #{!is_nil(user)}")

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        Logger.debug("Password verified for user: #{inspect(email)}")
        user

      user ->
        Logger.debug("Password verification failed for user: #{inspect(email)}")
        Bcrypt.hash_pwd_salt("dummy_password_for_timing")
        nil

      true ->
        Logger.debug("User not found for email: #{inspect(email)}")
        Bcrypt.hash_pwd_salt("dummy_password_for_timing")
        nil
    end
  end

  @doc """
  Updates a profile's seller status and description.
  """
  def update_profile_seller(%Profile{} = profile, attrs) do
    # Atomize keys before passing to changeset
    atom_attrs = Enum.into(attrs, %{}, fn {k, v} -> {String.to_atom(k), v} end)

    Profile.seller_changeset(profile, atom_attrs)
    |> Repo.update()
  end

  @doc """
  Updates a profile's presence status.
  """
  def update_presence_status(%Profile{} = profile, status) do
    Profile.presence_changeset(profile, %{presence_status: status})
    |> Repo.update()
  end

  @doc """
  Lists sellers within a given viewport (radius from a central point).
  """
  def list_sellers_in_viewport(%Geo.Point{} = user_location, radius_meters) do
    radius_degrees = radius_meters / 111_000

    query =
      from(p in Profile,
        join: u in assoc(p, :user),
        where: p.is_seller == true,
        where: p.presence_status in ["online", "streaming"],
        where: fragment("ST_DWithin(?, ?, ?)", p.location_geom, ^user_location, ^radius_degrees),
        select: p
      )

    Repo.all(query)
  end
end
