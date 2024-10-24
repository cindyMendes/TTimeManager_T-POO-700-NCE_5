alias TimeManager.Accounts
alias TimeManager.Repo

require Logger

Logger.info("Starting database seeding...")

# Try to find the user first using get_user_by_email_and_username
# Since we need both email and username, we'll pass both
case Accounts.get_user_by_email_and_username("batadmin@gotham.com", "batadmin") do
  nil ->
    Logger.info("Creating general manager user...")

    # Create user with proper attributes
    user_params = %{
      username: "batadmin",
      email: "batadmin@gotham.com",
      password: "batadmin",
      role: "general_manager"
    }

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Logger.info("General manager created successfully with id: #{user.id}")

      {:error, changeset} ->
        Logger.error("Failed to create general manager")
        Logger.error("Errors: #{inspect(changeset.errors)}")
    end

  user ->
    Logger.info("General manager already exists with id: #{user.id}")
end

# You might want to create some other seed data here

Logger.info("Database seeding completed")
