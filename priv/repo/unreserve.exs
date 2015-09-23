# Script for unreserving all seats in the database. You can run it as:
#
#     mix run priv/repo/unreserve.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SeatSaver.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
SeatSaver.Repo.update_all(SeatSaver.Seat, set: [occupied: false])
