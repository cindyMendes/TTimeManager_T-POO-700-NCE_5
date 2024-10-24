defmodule TimeManager.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset
  alias TimeManager.Validators.InputSanitizer

  schema "teams" do
    field :name, :string
    belongs_to :manager, TimeManager.Accounts.User, foreign_key: :manager_id
    has_many :members, TimeManager.Accounts.User, foreign_key: :team_id
    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    # Sanitize inputs before casting
    sanitized_attrs = %{
      name: attrs |> get_attr(:name) |> InputSanitizer.sanitize_string(),
      manager_id: get_attr(attrs, :manager_id)
    }

    team
    |> cast(sanitized_attrs, [:name, :manager_id])
    |> validate_required([:name, :manager_id])
    |> validate_length(:name, min: 2, max: 100)
    |> foreign_key_constraint(:manager_id)
  end

  # Helper to safely get attributes from either string or atom keys
  defp get_attr(attrs, key) do
    attrs[key] || attrs[Atom.to_string(key)]
  end
end
