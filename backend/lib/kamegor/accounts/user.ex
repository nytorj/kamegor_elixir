<![CDATA[defmodule Kamegor.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Kamegor.Accounts.Profile
  alias Kamegor.Repo

  schema "users" do
    field :email, :string
    field :password_hash, :string

    # Virtual field for password changes
    field :password, :string, virtual: true

    # A user has one profile
    has_one :profile, Profile

    timestamps()
  end

  @doc """
  Builds a changeset for creating/updating a user.
  Handles password hashing.
  """
  def changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:password, min: 8, max: 72)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  @doc """
  Builds a changeset for changing a user's password.
  """
  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 72)
    |> put_password_hash()
  end

  # Hashes the password if it's present in the changeset
  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
]]>
