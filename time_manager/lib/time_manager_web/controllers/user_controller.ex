defmodule TimeManagerWeb.UserController do
  use TimeManagerWeb, :controller
  alias TimeManager.Accounts
  alias TimeManager.Accounts.User

  # def index(conn, _params) do
  #   users = Accounts.list_users()
  #   render(conn, :index, users: users)
  # end

  def show_user_by_email_and_username(conn, %{"username" => username, "email" => email}) do
    case Accounts.get_user_by_email_and_username(username, email) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{
          errors: %{
            detail: "User not found with provided email and username"
          }
        })

      user ->
        conn
        |> put_status(:ok)
        |> json(%{
          data: %{
            id: user.id,
            username: user.username,
            email: user.email,
            role: user.role,
            team_id: user.team_id,
            inserted_at: user.inserted_at,
            updated_at: user.updated_at
          }
        })
    end
  end

  def index(conn, _params) do
    users = Accounts.list_users()
    conn
    |> put_status(:ok)
    |> json(%{
      data: Enum.map(users, fn user ->
        %{
          id: user.id,
          username: user.username,
          email: user.email,
          role: user.role,
          team_id: user.team_id,
          inserted_at: user.inserted_at,
          updated_at: user.updated_at
        }
      end)
    })
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def show_user(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    conn
    |> put_status(:ok)
    |> json(%{
      data: %{
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        team_id: user.team_id,
        inserted_at: user.inserted_at,
        updated_at: user.updated_at
      }
    })
  rescue
    Ecto.NoResultsError ->
      conn
      |> put_status(:not_found)
      |> json(%{
        errors: %{
          detail: "User not found"
        }
      })
  end

  def show_user_by_email_and_username(conn, %{"username" => username, "email" => email}) do
    user = Accounts.get_user_by_email_and_username(username, email)
    render(conn, :show, user: user)
  end

  def create(conn, %{"user" => user_params}) do
    user_params = filter_user_params(user_params)

    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user.id}")
      |> render(:show, user: user)
    else
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(TimeManagerWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)
    user_params = filter_user_params(user_params)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    else
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(TimeManagerWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update_user(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)
    user_params = filter_user_params(user_params)

    case Accounts.update_user(user, user_params) do
      {:ok, updated_user} ->
        conn
        |> put_status(:ok)
        |> json(%{
          data: %{
            id: updated_user.id,
            username: updated_user.username,
            email: updated_user.email,
            role: updated_user.role,
            team_id: updated_user.team_id,
            inserted_at: updated_user.inserted_at,
            updated_at: updated_user.updated_at
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          errors: %{
            detail: format_changeset_errors(changeset)
          }
        })
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def delete_user(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    case Accounts.delete_user(user) do
      {:ok, deleted_user} ->
        conn
        |> put_status(:ok)
        |> json(%{
          data: %{
            id: deleted_user.id,
            username: deleted_user.username,
            email: deleted_user.email,
            role: deleted_user.role,
            team_id: deleted_user.team_id,
            inserted_at: deleted_user.inserted_at,
            updated_at: deleted_user.updated_at,
            message: "User successfully deleted"
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          errors: %{
            detail: format_changeset_errors(changeset)
          }
        })
    end
  rescue
    Ecto.NoResultsError ->
      conn
      |> put_status(:not_found)
      |> json(%{
        errors: %{
          detail: "User not found"
        }
      })
  end

  # Helper function to filter the incoming user params
  defp filter_user_params(user_params) do
    user_params
    |> Map.drop(["password_confirmation"]) # if you handle password confirmation
  end

  # Promote an employee to manager
  def promote(conn, %{"id" => id}) do
    user_to_promote = Accounts.get_user!(id)
    current_user = Guardian.Plug.current_resource(conn)

    cond do
      is_nil(current_user) ->
        conn
        |> put_status(:unauthorized)
        |> json(%{errors: %{detail: "Authentication required"}})
        
      current_user.role != "general_manager" ->
        conn
        |> put_status(:forbidden)
        |> json(%{errors: %{detail: "Only general managers can promote users"}})
        
      user_to_promote.role == "general_manager" ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: %{detail: "Cannot promote a general manager"}})
        
      true ->
        case Accounts.update_user_role(user_to_promote, "manager") do
          {:ok, updated_user} ->
            conn
            |> put_status(:ok)
            |> json(%{
              data: %{
                id: updated_user.id,
                username: updated_user.username,
                email: updated_user.email,
                role: updated_user.role
              }
            })
            
          {:error, :invalid_role} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: %{detail: "Invalid role specified"}})
            
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: %{detail: format_changeset_errors(changeset)}})
        end
    end
  end

  # Demote a manager to employee
  def demote(conn, %{"id" => id}) do
    user_to_demote = Accounts.get_user!(id)
    current_user = Guardian.Plug.current_resource(conn)

    cond do
      is_nil(current_user) ->
        conn
        |> put_status(:unauthorized)
        |> json(%{errors: %{detail: "Authentication required"}})
        
      current_user.role != "general_manager" ->
        conn
        |> put_status(:forbidden)
        |> json(%{errors: %{detail: "Only general managers can demote users"}})
        
      user_to_demote.role == "general_manager" ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: %{detail: "Cannot demote a general manager"}})
        
      true ->
        case Accounts.update_user_role(user_to_demote, "employee") do
          {:ok, updated_user} ->
            conn
            |> put_status(:ok)
            |> json(%{
              data: %{
                id: updated_user.id,
                username: updated_user.username,
                email: updated_user.email,
                role: updated_user.role
              }
            })
            
          {:error, :invalid_role} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: %{detail: "Invalid role specified"}})
            
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: %{detail: format_changeset_errors(changeset)}})
        end
    end
  end

  # Helper function to get the current user role
  defp current_user_role(conn) do
    # Function to retrieve the current authenticated user
    current_user = get_current_user(conn)
    current_user.role
  end

  defp get_current_user(conn) do
    conn.assigns[:current_user]
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

end
