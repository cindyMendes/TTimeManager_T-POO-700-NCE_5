defmodule TimeManager.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    belongs_to :manager, TimeManager.Accounts.User, foreign_key: :manager_id  # Defines the manager relationship
    has_many :members, TimeManager.Accounts.User, foreign_key: :team_id
    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :manager_id])
    |> validate_required([:name, :manager_id])
    |> foreign_key_constraint(:manager_id)  # Ensure it’s a valid user reference
  end
end
