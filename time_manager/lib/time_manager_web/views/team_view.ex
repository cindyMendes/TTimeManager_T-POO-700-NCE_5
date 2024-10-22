defmodule TimeManagerWeb.TeamView do
  use TimeManagerWeb, :view

  # Rendre la liste des équipes
  def render("index.json", %{teams: teams}) do
    %{data: Enum.map(teams, fn team ->
      %{
        id: team.id,
        name: team.name,
        manager_id: team.manager_id
      }
    end)}
  end

  # Rendre une équipe individuelle
  def render("team.json", %{team: team}) do
    %{
      id: team.id,
      name: team.name,
      manager_id: team.manager_id
    }
  end

  # Rendre une équipe avec ses membres
  def render("show_with_members.json", %{team: team}) do
    %{
      data: %{
        id: team.id,
        name: team.name,
        manager_id: team.manager_id,
        members: for member <- team.members do
          %{
            id: member.id,
            username: member.username,
            email: member.email,
            role: member.role
          }
        end,
        inserted_at: team.inserted_at
      }
    }
  end

end
