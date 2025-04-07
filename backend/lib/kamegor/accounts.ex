<![CDATA[defmodule Kamegor.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Kamegor.Repo

  alias Kamegor.Accounts.User
  alias Kamegor.Accounts.Profile

  @doc """
  Registers a new user with an associated profile.

  ## Examples

      iex> register_user(%{email: "test@example.com", password: "password123", username: "tester"})
      {:ok, %User{}}

      iex> register_user(%{email: "invalid", password: "short", username: "tester"})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    # Extract profile attrs (username) and user attrs (email, password)
    profile_attrs = Map.take(attrs, [:username])
    user_attrs = Map.take(attrs, [:email, :password])

    # Use a transaction to ensure both user and profile are created or neither is.
    Repo.transaction(fn ->
      case User.changeset(%User{}, user_attrs) do
        %Ecto.Changeset{valid?: true} = user_changeset ->
          case Repo.insert(user_changeset) do
            {:ok, user} ->
              # Add user_id to profile attributes before creating profile changeset
              profile_attrs_with_user_id = Map.put(profile_attrs, :user_id, user.id)

              case Profile.changeset(%Profile{}, profile_attrs_with_user_id) do
                %Ecto.Changeset{valid?: true} = profile_changeset ->
                  case Repo.insert(profile_changeset) do
                    {:ok, _profile} ->
                      # Return the created user if everything succeeded
                      {:ok, user}
                    {:error, profile_changeset_error} ->
                      # Rollback transaction and return profile error
                      Repo.rollback(profile_changeset_error)
                  end
                %Ecto.Changeset{} = profile_changeset_error ->
                  # Rollback transaction and return profile error
                  Repo.rollback(profile_changeset_error)
              end
            {:error, user_changeset_error} ->
              # Rollback transaction and return user error
              Repo.rollback(user_changeset_error)
          end
        %Ecto.Changeset{} = user_changeset_error ->
          # No need to rollback as nothing was inserted yet
          {:error, user_changeset_error}
      end
    end)
  end

  @doc """
  Returns the user with the given email, preloading the profile.
  Returns nil if no user is found.
  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
    |> Repo.preload(:profile)
  end

  @doc """
  Authenticates a user by email and password.
  Returns the user if authentication is successful, otherwise nil.
  """
  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        user
      true ->
        # Optionally hash a dummy password to prevent timing attacks
        Bcrypt.hash_pwd_salt("dummy_password_for_timing")
        nil
    end
  end

  # Add other context functions here (get_user!, update_user, etc.) as needed
end
]]>
