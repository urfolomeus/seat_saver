defmodule SeatSaver.SeatChannel do
  use SeatSaver.Web, :channel

  import Ecto.Query

  alias SeatSaver.Seat

  def join("seats:planner", payload, socket) do
    seats = (from s in Seat, order_by: [asc: s.seat_no]) |> Repo.all
    {:ok, seats, socket}
  end

  def handle_in("request_seat", payload, socket) do
    # sanity check out to the log in case things go awry!
    IO.puts {:request_seat, payload} |> inspect

    # fetch the requested seat from the database
    seat = Repo.get!(SeatSaver.Seat, payload["seatNo"])

    # create an update that will mark the seat as occupied
    seat_params = %{"occupied" => true}
    changeset = SeatSaver.Seat.changeset(seat, seat_params)

    # run the update, if it was successful broadcast the seat that
    # was occupied to all subscribers, otherwise reply to the originator
    # with an error
    case Repo.update(changeset) do
      {:ok, seat} ->
        broadcast socket, "occupied", payload
        {:noreply, socket}
      {:error, changeset} ->
        {:reply, {:error, %{message: "Something went wrong"}}, socket}
    end
  end
end
