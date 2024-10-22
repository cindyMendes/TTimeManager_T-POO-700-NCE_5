defmodule TimeManager.Teams do
  import Ecto.Query, warn: false
  alias TimeManager.Repo
  alias TimeManager.Teams.Team

  # Lister toutes les équipes
  # def list_teams do
  #   Repo.all(Team)
  # end


  def list_teams do
    Repo.all(Team)
    |> Repo.preload([:manager, :members])
  end



  # Récupérer une équipe par son ID
  def get_team!(id), do: Repo.get!(Team, id)

  # Créer une nouvelle équipe
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  # Mettre à jour une équipe existante
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  # Supprimer une équipe
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end




   # Récupérer une équipe avec ses membres (utilisateurs qui ont team_id défini)
   def get_team_with_members!(id) do
    Repo.get!(Team, id)
    |> Repo.preload(:members)  # Précharger les membres de l'équipe
  end





end
