defmodule TimeManager.Validators.InputSanitizer do
  @moduledoc """
  Provides input sanitization and validation functions to protect against injections
  """

  def sanitize_string(nil), do: nil
  def sanitize_string(str) when is_binary(str) do
    str
    |> String.trim()
    |> String.replace(~r/[[:cntrl:]]/, "")
    |> String.replace(~r/[<>]/, "")
    |> String.slice(0, 255)
  end

  def sanitize_email(nil), do: nil
  def sanitize_email(email) when is_binary(email) do
    email
    |> String.trim()
    |> String.downcase()
    |> validate_email_format()
  end

  @doc """
  Validates and sanitizes a datetime input
  """
  def sanitize_datetime(nil), do: nil
  def sanitize_datetime(%DateTime{} = datetime), do: datetime
  def sanitize_datetime(datetime) when is_binary(datetime) do
    case DateTime.from_iso8601(datetime) do
      {:ok, datetime, _offset} -> datetime
      {:error, _} -> nil
    end
  rescue
    _ -> nil
  end

  @doc """
  Validates and sanitizes a boolean input
  """
  def sanitize_boolean(nil), do: false
  def sanitize_boolean(bool) when is_boolean(bool), do: bool
  def sanitize_boolean("true"), do: true
  def sanitize_boolean("false"), do: false
  def sanitize_boolean(1), do: true
  def sanitize_boolean(0), do: false
  def sanitize_boolean(_), do: false

  @doc """
  Validates and sanitizes a user ID
  """
  def sanitize_user_id(nil), do: nil
  def sanitize_user_id(id) when is_integer(id), do: id
  def sanitize_user_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int_id, ""} when int_id > 0 -> int_id
      _ -> nil
    end
  end
  def sanitize_user_id(_), do: nil

  defp validate_email_format(email) do
    case Regex.match?(~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/, email) do
      true -> email
      false -> nil
    end
  end
end
