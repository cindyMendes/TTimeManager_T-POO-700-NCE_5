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

alias TimeManager.Accounts.User
alias TimeManager.Repo

IO.puts "Checking for general manager user..."

case Repo.get_by(User, email: "batman@gotham.com") do
  nil ->
    IO.puts "Creating general manager user..."

    %User{}
    |> User.changeset(%{
      username: "batman",
      email: "batman@gotham.com",
      password: "batman",
      role: "general_manager"
    })
    |> Repo.insert!()

    IO.puts "General manager user created successfully!"

  user ->
    IO.puts "General manager user already exists: #{user.username}"
end
