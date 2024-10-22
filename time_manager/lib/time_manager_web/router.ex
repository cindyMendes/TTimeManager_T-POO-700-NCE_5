defmodule TimeManagerWeb.Router do
  use TimeManagerWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:put_view, json: TimeManagerWeb.ErrorJSON)
    plug TimeManagerWeb.Plugs.GuardianFetchCurrentUser
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: TimeManagerWeb.Guardian,
      error_handler: TimeManagerWeb.AuthErrorHandler
    plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated
end

  # pipeline :auth do
  #   plug(TimeManagerWeb.Plugs.Authenticate)
  # end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  pipeline :employee_auth do
    plug(TimeManagerWeb.Plugs.EnsureRole, [:employee, :manager, :general_manager])
  end

  pipeline :manager_auth do
    plug(TimeManagerWeb.Plugs.EnsureRole, [:manager, :general_manager])
  end

  pipeline :general_manager_auth do
    plug TimeManagerWeb.Plugs.EnsureRole, ["general_manager"]
  end

  scope "/api", TimeManagerWeb do
    pipe_through(:api)

    # Auth routes (non protégées)
    post("/auth/login", AuthController, :login)
    post("/auth/signup", AuthController, :signup)
  end

  scope "/api", TimeManagerWeb do
    pipe_through([:api, :auth, :ensure_auth])

    # Routes for all authenticated users
    get("/users/profile", UserController, :show_current_user)
    put("/users/profile", UserController, :update_current_user)
    delete("/users/profile", UserController, :delete_current_user)

    resources("/workingtimes", WorkingTimeController,
      only: [:index, :show, :create, :update, :delete]
    )

    resources("/clocks", ClockController, only: [:index, :create, :show])

    get("/dashboard", DashboardController, :show)
  end

  scope "/api", TimeManagerWeb do
    pipe_through([:api, :auth, :ensure_auth, :manager_auth])

    # Routes for managers and general managers
    resources("/teams", TeamController, except: [:new, :edit])
    get("/teams/:id/members", TeamController, :show_members)
    post("/teams/:id/members/:user_id", TeamController, :add_member)
    delete("/teams/:id/members/:user_id", TeamController, :remove_member)

    get("/reports/team/:team_id/daily_hours", ReportController, :team_daily_hours)
    get("/reports/team/:team_id/weekly_hours", ReportController, :team_weekly_hours)
    get("/reports/employee/:user_id/daily_hours", ReportController, :employee_daily_hours)
    get("/reports/employee/:user_id/weekly_hours", ReportController, :employee_weekly_hours)
  end

  scope "/api", TimeManagerWeb do
    pipe_through([:api, :auth, :ensure_auth, :general_manager_auth])

    # Routes for general manager only
    get("/users", UserController, :index)
    delete("/users/:id", UserController, :delete)

    # Report routes
    get("/reports/daily_hours", ReportController, :daily_hours)
    get("/reports/weekly_hours", ReportController, :weekly_hours)

    # Working Time routes
    get("/workingtimes", WorkingTimeController, :index)
    get("/workingtimes/:user_id/times", WorkingTimeController, :show_user)
    get("/workingtimes/:user_id", WorkingTimeController, :show_user_working_time)
    get("/workingtime/:id", WorkingTimeController, :show)
    post("/workingtime/:user_id", WorkingTimeController, :create)
    put("/workingtime/:id", WorkingTimeController, :update)
    delete("/workingtime/:id", WorkingTimeController, :delete)

    # Clocking routes
    get("/clocks", ClockController, :index)
    post("/clocks/:user_id", ClockController, :create)
    get("/clocks/:user_id", ClockController, :show)

    # Team routes
    resources("/teams", TeamController, except: [:new, :edit])

    # Route pour associer un utilisateur à une équipe
    put("/teams/:team_id/users/:user_id", TeamController, :add_user_to_team)

    #supprimer un membre d'équipe
    delete "/teams/:team_id/members/:user_id", TeamController, :remove_member


    get("/reports/company/daily_hours", ReportController, :company_daily_hours)
    get("/reports/company/weekly_hours", ReportController, :company_weekly_hours)

    # Promote and demote routes
    put "/users/:id/promote", UserController, :promote
    put "/users/:id/demote", UserController, :demote
  end
end
