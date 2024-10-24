# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TimeManager.Repo.insert!(%TimeManager.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# In priv/repo/seeds.exs

alias TimeManager.Accounts
alias TimeManager.Repo

require Logger

Logger.info("Starting database seeding...")

# Create general manager if not exists
case Accounts.get_user_by_email("batadmin@gotham.com") do
  nil ->
    Logger.info("Creating general manager user...")
    {:ok, _user} = Accounts.create_user(%{
      username: "batadmin",
      email: "batadmin@gotham.com",
      password: "batadmin",
      role: "general_manager"
    })
    Logger.info("General manager created successfully")

  _user ->
    Logger.info("General manager already exists")
end

Logger.info("Database seeding completed")
