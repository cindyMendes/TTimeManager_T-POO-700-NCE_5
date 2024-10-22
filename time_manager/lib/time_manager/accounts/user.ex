defmodule TimeManager.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  # schema "users" do
  #   field :username, :string
  #   field :email, :string
  #   field :role, :string, default: "user"
  #   belongs_to :team, TimeManager.Teams.Team
  #   field :password, :string, virtual: true  # Virtual field for plain text password
  #   field :password_hash, :string

  #   has_many :managed_teams, TimeManager.Teams.Team, foreign_key: :manager_id  # This adds the relation for managed teams

  #   timestamps(type: :utc_datetime)
  # end

  # @doc false
  # def changeset(user, attrs) do
  #   user
  #   |> cast(attrs, [:username, :email, :role, :team_id, :password])
  #   |> validate_required([:username, :email, :role])
  #   |> unique_constraint(:email, name: "users_email_index")
  #   |> validate_length(:password, min: 6)
  #   |> put_password_hash()
  # end

  @roles ["general_manager", "manager", "employee"]  # Define valid roles

  @derive {Jason.Encoder, only: [:id, :username, :email, :role, :team_id, :inserted_at, :updated_at]}

  schema "users" do
    field :username, :string
    field :email, :string
    field :role, :string, default: "employee"
    belongs_to :team, TimeManager.Teams.Team
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :managed_teams, TimeManager.Teams.Team, foreign_key: :manager_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :role, :team_id, :password])
    |> validate_required([:username, :email, :role])
    |> validate_inclusion(:role, @roles)  # Add validation for roles
    |> unique_constraint(:email, name: "users_email_index")
    |> validate_length(:password, min: 6)
    |> put_password_hash()
  end

  # Function to hash the password using PBKDF2
  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset
      password ->
        hash = Pbkdf2.hash_pwd_salt(password)
        put_change(changeset, :password_hash, hash)
    end
  end

  defp get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

end
