# defmodule TimeManagerWeb.Guardian do
#   use Guardian, otp_app: :time_manager

#   alias TimeManager.Accounts

#   # Function to encode a resource (usually the user)
#   def subject_for_token(user, _claims) do
#     {:ok, to_string(user.id)}
#   end

#   # Function to decode a token and return the resource (user)
#   def resource_from_claims(%{"sub" => id}) do
#     user = Accounts.get_user!(id)
#     {:ok, user}
#   rescue
#     Ecto.NoResultsError -> {:error, :resource_not_found}
#   end
# end


defmodule TimeManagerWeb.Guardian do
  use Guardian, otp_app: :time_manager

  alias TimeManager.Accounts

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = Accounts.get_user!(id)
    IO.inspect(user, label: "User loaded in Guardian")
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end