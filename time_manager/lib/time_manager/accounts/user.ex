defmodule TimeManager.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias TimeManager.Validators.InputSanitizer

  @roles ["general_manager", "manager", "employee"]

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
    # Sanitize inputs before casting
    sanitized_attrs = %{
      username: attrs |> get_attr(:username) |> InputSanitizer.sanitize_string(),
      email: attrs |> get_attr(:email) |> InputSanitizer.sanitize_email(),
      role: get_attr(attrs, :role),
      team_id: get_attr(attrs, :team_id),
      password: get_attr(attrs, :password)
    }

    user
    |> cast(sanitized_attrs, [:username, :email, :role, :team_id, :password])
    |> validate_required([:username, :email, :role])
    |> validate_inclusion(:role, @roles)
    |> validate_format(:email, ~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/)
    |> unique_constraint(:email, name: "users_email_index")
    |> validate_length(:username, min: 3, max: 30)
    |> validate_length(:password, min: 6, max: 100)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password ->
        hash = Pbkdf2.hash_pwd_salt(password)
        put_change(changeset, :password_hash, hash)
    end
  end

  defp get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  # Helper to safely get attributes from either string or atom keys
  defp get_attr(attrs, key) do
    attrs[key] || attrs[Atom.to_string(key)]
  end
end
