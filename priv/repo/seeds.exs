# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SeatSaver.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 1, occupied: false})
SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 2, occupied: false})
SeatSaver.Repo.insert!(%SeatSaver.Seat{seat_no: 3, occupied: false})
