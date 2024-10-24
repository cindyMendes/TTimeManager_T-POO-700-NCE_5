defmodule TimeManager.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias TimeManager.Repo

  alias TimeManager.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  # def create_user(attrs \\ %{}) do
  #   %User{}
  #   |> User.changeset(attrs)
  #   |> Repo.insert()
  # end
  def create_user(attrs \\ %{}) do
    changeset = User.changeset(%User{}, attrs)

    IO.inspect(changeset, label: "User Changeset")

    case Repo.insert(changeset) do
      {:ok, user} ->
        {:ok, user}
      {:error, changeset} ->
        IO.inspect(changeset, label: "Changeset Error")
        {:error, changeset}
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Returns user filtered by email and username.

  ## Examples

      iex> get_user_by_email_and_username("test@example.com", "testuser")
      [%User{}, ...]

      iex> get_user_by_email_and_username("invalid@example.com", "invaliduser")
      []

  """
  def get_user_by_email_and_username(username, email) do
    query =
      from u in User,
        where: u.email == ^email and u.username == ^username

    Repo.one(query)
  end

  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)
    case user do
      nil ->
        {:error, :unauthorized}
      user ->
        if Pbkdf2.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :unauthorized}
        end
    end
  end

  @doc """
  Updates user role
  """

  # def update_user_role(%User{} = user, new_role) do
  #   IO.inspect(user, label: "User before role update")
  #   IO.inspect(new_role, label: "New role")

  #   changeset = User.changeset(user, %{role: new_role})

  #   IO.inspect(changeset, label: "Changeset before update")

  #   case Repo.update(changeset) do
  #     {:ok, updated_user} = result ->
  #       IO.inspect(updated_user, label: "Successfully updated user")
  #       result
  #     {:error, changeset} = error ->
  #       IO.inspect(changeset, label: "Update failed with changeset")
  #       error
  #   end
  # end
  def debug_update_user(%User{} = user, attrs) do
    IO.inspect(attrs, label: "Update User Attrs")

    changeset = User.changeset(user, attrs)

    IO.inspect(changeset.valid?, label: "Changeset Valid?")
    IO.inspect(changeset.errors, label: "Changeset Errors")
    IO.inspect(changeset.changes, label: "Changeset Changes")

    case Repo.update(changeset) do
      {:ok, updated_user} ->
        IO.inspect(updated_user, label: "Successfully Updated User")
        {:ok, updated_user}
      {:error, failed_changeset} ->
        IO.inspect(failed_changeset.errors, label: "Update Failed - Errors")
        {:error, failed_changeset}
    end
  end
end
