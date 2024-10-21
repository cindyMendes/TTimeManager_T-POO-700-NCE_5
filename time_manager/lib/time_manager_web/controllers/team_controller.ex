defmodule TimeManagerWeb.TeamController do
  use TimeManagerWeb, :controller

  alias TimeManager.Teams
  alias TimeManager.Teams.Team
  alias TimeManager.Accounts

  # GET /teams - Lister toutes les équipes
  # def index(conn, _params) do
  #   teams = Teams.list_teams()
  #   render(conn, "index.json", teams: teams)
  # end
  def index(conn, _params) do
    teams = Teams.list_teams()

    case teams do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{errors: %{detail: "Aucune équipe trouvée"}})

      _ ->
        render(conn, "index.json", teams: teams)
    end
  end


  # GET /teams/:id - Récupérer une équipe spécifique
  # def show(conn, %{"id" => id}) do
  #   team = Teams.get_team!(id)
  #   render(conn, "show.json", team: team)
  # end

  # POST /teams - Créer une nouvelle équipe
  def create(conn, %{"team" => team_params}) do
    with {:ok, %Team{} = team} <- Teams.create_team(team_params) do
      conn
      |> put_status(:created)
      |> render("show.json", team: team)
    end
  end

  # PUT /teams/:id - Mettre à jour une équipe
  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Teams.get_team!(id)

    with {:ok, %Team{} = team} <- Teams.update_team(team, team_params) do
      render(conn, "show.json", team: team)
    end
  end

  # DELETE /teams/:id - Supprimer une équipe
  def delete(conn, %{"id" => id}) do
    team = Teams.get_team!(id)

    with {:ok, %Team{}} <- Teams.delete_team(team) do
      send_resp(conn, :no_content, "")
    end
  end

   # GET /teams/:id - Récupérer une équipe spécifique avec ses membres
   def show(conn, %{"id" => id}) do
    team = Teams.get_team_with_members!(id)
    render(conn, "show_with_members.json", team: team)
  end

    # PUT /teams/:team_id/users/:user_id - Ajouter un utilisateur à une équipe
def add_user_to_team(conn, %{"team_id" => team_id, "user_id" => user_id}) do
  user = Accounts.get_user!(user_id)

  case Accounts.update_user(user, %{team_id: team_id}) do
    {:ok, user} ->
      json(conn, %{message: "User successfully added to team", user: user})
    {:error, changeset} ->
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{errors: changeset})
  end
end


end
