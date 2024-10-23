defmodule TimeManagerWeb.ClockJSON do
  alias TimeManager.TimeTracking.Clock

  # Renders a list of clocks for the index action
  def index(%{clocks: clocks}) do
    %{data: for(clock <- clocks, do: clock_to_json(clock))}
  end

  # Renders a single clock for the show action
  def show(%{clock: clock}) do
    %{
      data: %{
        id: clock.id,
        user_id: clock.user_id,
        time: clock.time,
        status: clock.status
      }
    }
  end

  # Helper function to render a clock as JSON
  defp clock_to_json(%Clock{id: id, time: time, status: status, user_id: user_id}) do
    %{
      id: id,
      time: time,
      status: status,
      user_id: user_id
    }
  end
end
