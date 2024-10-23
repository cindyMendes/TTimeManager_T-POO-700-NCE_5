defmodule TimeManagerWeb.ClockController do
  use TimeManagerWeb, :controller

  alias TimeManager.TimeTracking
  alias TimeManager.TimeTracking.Clock

  action_fallback TimeManagerWeb.FallbackController

  def create(conn, %{"user_id" => user_id, "status" => status, "time" => time}) do
    clock_params = %{"user_id" => user_id, "status" => status, "time" => time}

    with {:ok, %Clock{} = clock} <- TimeTracking.create_clock(clock_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/clocks/#{clock.id}")
      |> render(:show, clock: clock)  # <=== Assure-toi que `:show` est bien défini
    else
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(TimeManagerWeb.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end


  # def show(conn, %{"user_id" => user_id}) do
  #   clocks = TimeTracking.list_clocks_by_user_id(user_id)
  #   conn
  #   |> put_view(TimeManagerWeb.ClockJSON)
  #   |> render("index.json", clocks: clocks)
  # end


  def show(conn, %{"user_id" => user_id}) do
    clocks = TimeTracking.list_clocks_for_user(user_id)

    if clocks == [] do
      conn
      |> put_status(:not_found)
      |> json(%{error: "Aucune horloge trouvée pour l'utilisateur avec l'ID #{user_id}."})
    else
      conn
      |> put_view(TimeManagerWeb.ClockJSON)
      |> render("index.json", clocks: clocks)
    end
  end






  def index(conn, _params) do
    clocks = TimeTracking.list_clocks()
    conn
    |> put_view(TimeManagerWeb.ClockJSON)
    |> render("index.json", clocks: clocks)
  end

end
