defmodule TimeManager.TimeTracking.Clock do
  use Ecto.Schema
  import Ecto.Changeset
  alias TimeManager.Validators.InputSanitizer

  schema "clocks" do
    field :status, :boolean, default: false
    field :time, :utc_datetime
    belongs_to :user, TimeManager.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(clock, attrs) do
    # Sanitize inputs before casting
    sanitized_attrs = %{
      time: attrs |> get_attr(:time) |> InputSanitizer.sanitize_datetime(),
      status: attrs |> get_attr(:status) |> InputSanitizer.sanitize_boolean(),
      user_id: attrs |> get_attr(:user_id) |> InputSanitizer.sanitize_user_id()
    }

    clock
    |> cast(sanitized_attrs, [:time, :status, :user_id])
    |> validate_required([:time, :status, :user_id])
    |> foreign_key_constraint(:user_id)
    |> validate_time_not_future()
  end

  # Helper to safely get attributes from either string or atom keys
  defp get_attr(attrs, key) do
    attrs[key] || attrs[Atom.to_string(key)]
  end

  # Validate that clock time is not in the future
  defp validate_time_not_future(changeset) do
    case get_change(changeset, :time) do
      nil -> changeset
      time ->
        if DateTime.compare(time, DateTime.utc_now()) == :gt do
          add_error(changeset, :time, "cannot be in the future")
        else
          changeset
        end
    end
  end
end
