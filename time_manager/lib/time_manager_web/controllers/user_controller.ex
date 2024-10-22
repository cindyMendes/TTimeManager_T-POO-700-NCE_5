defmodule TimeManagerWeb.UserController do
  use TimeManagerWeb, :controller
  alias TimeManager.Accounts
  alias TimeManager.Accounts.User

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
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

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
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

    if current_user && current_user.role == "general_manager" do
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
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: %{detail: format_changeset_errors(changeset)}})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{errors: %{detail: "Not authorized"}})
    end
  end

  # Demote a manager to employee
  def demote(conn, %{"id" => id}) do
    user_to_demote = Accounts.get_user!(id)
    current_user = Guardian.Plug.current_resource(conn)

    if current_user && current_user.role == "general_manager" do
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
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: %{detail: format_changeset_errors(changeset)}})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{errors: %{detail: "Not authorized"}})
    end
  end

  # Helper function to get the current user role
  defp current_user_role(conn) do
    # Assuming there's a function to retrieve the current authenticated user
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