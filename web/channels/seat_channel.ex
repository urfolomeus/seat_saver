defmodule SeatSaver.SeatChannel do
  use SeatSaver.Web, :channel

  def join("seats:planner", payload, socket) do
    {:ok, socket}
  end
end
