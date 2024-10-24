defmodule TimeManagerWeb.TeamController do
  use TimeManagerWeb, :controller

  alias TimeManager.Teams
  alias TimeManager.Teams.Team
  alias TimeManager.Accounts

  # Existing index function remains the same
  def index(conn, _params) do
    teams = Teams.list_teams()

    conn
    |> put_status(:ok)
    |> json(%{
      data: Enum.map(teams, fn team ->
        %{
          id: team.id,
          name: team.name,
          manager: %{
            id: team.manager.id,
            username: team.manager.username,
            email: team.manager.email,
            role: team.manager.role,
            inserted_at: team.manager.inserted_at,
            updated_at: team.manager.updated_at
          },
          members: Enum.map(team.members, fn member ->
            %{
              id: member.id,
              username: member.username,
              email: member.email,
              role: member.role,
              inserted_at: member.inserted_at,
              updated_at: member.updated_at
            }
          end),
          inserted_at: team.inserted_at,
          updated_at: team.updated_at
        }
      end)
    })
  end

  def create(conn, %{"team" => team_params}) do
    with {:ok, %Team{} = team} <- Teams.create_team(team_params) do
      conn
      |> put_status(:created)
      |> render("show.json", team: team)
    end
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Teams.get_team!(id)

    with {:ok, %Team{} = team} <- Teams.update_team(team, team_params) do
      render(conn, "show.json", team: team)
    end
  end

  def delete(conn, %{"id" => id}) do
    team = Teams.get_team!(id)

    with {:ok, %Team{}} <- Teams.delete_team(team) do
      send_resp(conn, :no_content, "")
    end
  end

  def show(conn, %{"id" => id}) do
    team = Teams.get_team_with_members!(id)
    render(conn, "show_with_members.json", team: team)
  end

  # Updated add_user_to_team function with proper error handling
  def add_user_to_team(conn, %{"team_id" => team_id, "user_id" => user_id}) do
    IO.inspect(%{team_id: team_id, user_id: user_id}, label: "Received Parameters")

    # Get and inspect user and team
    user = Accounts.get_user!(user_id)
    team = Teams.get_team!(team_id)

    IO.inspect(user, label: "User to update")
    IO.inspect(team, label: "Target team")

    # Create update params and validate team exists
    update_params = %{
      "team_id" => team_id,
      "role" => user.role  # Preserve existing role
    }

    IO.inspect(update_params, label: "Update Parameters")

    # Attempt to update with more detailed error handling
    case Accounts.update_user(user, update_params) do
      {:ok, updated_user} ->
        IO.inspect(updated_user, label: "Successfully Updated User")
        conn
        |> put_status(:ok)
        |> json(%{
          data: %{
            message: "User successfully added to team",
            user: %{
              id: updated_user.id,
              username: updated_user.username,
              email: updated_user.email,
              role: updated_user.role,
              team_id: updated_user.team_id,
              inserted_at: updated_user.inserted_at,
              updated_at: updated_user.updated_at
            }
          }
        })

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset.errors, label: "Validation Errors")
        IO.inspect(changeset.valid?, label: "Changeset Valid?")
        IO.inspect(changeset.changes, label: "Attempted Changes")

        error_messages = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)

        IO.inspect(error_messages, label: "Formatted Error Messages")

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          errors: error_messages,
          details: "Failed to add user to team. Please check the error messages."
        })

      {:error, other_error} ->
        IO.inspect(other_error, label: "Unexpected Error")
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          errors: ["An unexpected error occurred while updating the user"],
          details: inspect(other_error)
        })
    end
  rescue
    e in Ecto.NoResultsError ->
      IO.inspect(e, label: "Not Found Error")
      conn
      |> put_status(:not_found)
      |> json(%{errors: ["User or team not found"]})

    e in _ ->
      IO.inspect(e, label: "Unexpected Exception")
      conn
      |> put_status(:internal_server_error)
      |> json(%{errors: ["An unexpected error occurred"]})
  end

  # Updated remove_member function with proper error handling
  def remove_member(conn, %{"id" => team_id, "user_id" => user_id}) do
    user = Accounts.get_user!(user_id)

    case Accounts.update_user(user, %{team_id: nil}) do
      {:ok, updated_user} ->
        conn
        |> put_status(:ok)
        |> json(%{
          data: %{
            message: "Member successfully removed from the team",
            user: %{
              id: updated_user.id,
              username: updated_user.username,
              email: updated_user.email,
              role: updated_user.role,
              team_id: updated_user.team_id,
              inserted_at: updated_user.inserted_at,
              updated_at: updated_user.updated_at
            }
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)
        })
    end
  end
end
