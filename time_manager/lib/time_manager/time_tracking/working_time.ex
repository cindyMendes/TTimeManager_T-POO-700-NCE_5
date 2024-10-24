defmodule TimeManager.TimeTracking.WorkingTime do
  use Ecto.Schema
  import Ecto.Changeset
  alias TimeManager.Validators.InputSanitizer

  schema "workingtimes" do
    field :start, :utc_datetime
    field :end, :utc_datetime
    belongs_to :user, TimeManager.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(working_time, attrs) do
    # Sanitize inputs before casting
    sanitized_attrs = %{
      start: attrs |> get_attr(:start) |> InputSanitizer.sanitize_datetime(),
      end: attrs |> get_attr(:end) |> InputSanitizer.sanitize_datetime(),
      user_id: attrs |> get_attr(:user_id) |> InputSanitizer.sanitize_user_id()
    }

    working_time
    |> cast(sanitized_attrs, [:start, :end, :user_id])
    |> validate_required([:start, :end, :user_id])
    |> foreign_key_constraint(:user_id)
    |> validate_time_order()
    |> validate_times_not_future()
    |> validate_reasonable_duration()
  end

  # Helper to safely get attributes from either string or atom keys
  defp get_attr(attrs, key) do
    attrs[key] || attrs[Atom.to_string(key)]
  end

  # Validate that end time is after start time
  defp validate_time_order(changeset) do
    case {get_field(changeset, :start), get_field(changeset, :end)} do
      {start, end_time} when not is_nil(start) and not is_nil(end_time) ->
        if DateTime.compare(end_time, start) == :lt do
          add_error(changeset, :end, "must be after start time")
        else
          changeset
        end
      _ -> changeset
    end
  end

  # Validate that times are not in the future
  defp validate_times_not_future(changeset) do
    now = DateTime.utc_now()

    changeset
    |> validate_time_not_future(:start, now)
    |> validate_time_not_future(:end, now)
  end

  defp validate_time_not_future(changeset, field, now) do
    case get_field(changeset, field) do
      nil -> changeset
      time ->
        if DateTime.compare(time, now) == :gt do
          add_error(changeset, field, "cannot be in the future")
        else
          changeset
        end
    end
  end

  # Validate that the duration is reasonable (e.g., not more than 24 hours)
  defp validate_reasonable_duration(changeset) do
    case {get_field(changeset, :start), get_field(changeset, :end)} do
      {start, end_time} when not is_nil(start) and not is_nil(end_time) ->
        duration = DateTime.diff(end_time, start, :hour)
        if duration > 24 do
          add_error(changeset, :end, "duration cannot exceed 24 hours")
        else
          changeset
        end
      _ -> changeset
    end
  end
end
