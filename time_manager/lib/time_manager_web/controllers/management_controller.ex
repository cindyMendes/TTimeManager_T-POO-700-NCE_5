defmodule TimeManagerWeb.ManagementController do
  use TimeManagerWeb, :controller
  alias TimeManager.Accounts
  alias TimeManager.Accounts.User
  alias TimeManager.Repo
  import Ecto.Query, warn: false

  def list_non_general_managers(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    
    if current_user.role != "general_manager" do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Unauthorized access"})
    else
      users = 
        User
        |> where([u], u.role != "general_manager")
        |> select([u], %{
          id: u.id,
          username: u.username,
          role: u.role
        })
        |> Repo.all()

      conn
      |> put_status(:ok)
      |> json(%{users: users})
    end
  rescue
    error ->
      conn
      |> put_status(:internal_server_error)
      |> json(%{error: "Failed to fetch users: #{inspect(error)}"})
  end

  def list_managers(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    
    if current_user.role != "general_manager" do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Unauthorized access"})
    else
      users = 
        User
        |> where([u], u.role == "manager")
        |> select([u], %{
          id: u.id,
          username: u.username,
          role: u.role
        })
        |> Repo.all()

      conn
      |> put_status(:ok)
      |> json(%{users: users})
    end
  rescue
    error ->
      conn
      |> put_status(:internal_server_error)
      |> json(%{error: "Failed to fetch users: #{inspect(error)}"})
  end

  def list_employees(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    
    if current_user.role != "general_manager" do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Unauthorized access"})
    else
      users = 
        User
        |> where([u], u.role == "employee")
        |> select([u], %{
          id: u.id,
          username: u.username,
          role: u.role
        })
        |> Repo.all()

      conn
      |> put_status(:ok)
      |> json(%{users: users})
    end
  rescue
    error ->
      conn
      |> put_status(:internal_server_error)
      |> json(%{error: "Failed to fetch users: #{inspect(error)}"})
  end
end