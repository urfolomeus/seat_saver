module SeatSaver where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- MODEL

type alias Seat =
  { seatNo : Int
  , occupied : Bool
  }


type alias Model =
  List Seat


initialModel : Model
initialModel =
  []


-- UPDATE

type Action = NoOp | AddSeats Model | Reserve Int


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model
    AddSeats seats ->
      seats
    Reserve seatNo ->
      let
        updateSeat s =
          if s.seatNo == seatNo then { s | occupied <- True } else s
      in
        List.map updateSeat model


-- VIEW

view : Signal.Address Seat -> Model -> Html
view address model =
  ul [ class "seats" ] ( List.map (seatItem address) model )


seatItem : Signal.Address Seat -> Seat -> Html
seatItem address seat =
  let
    occupiedClass = if seat.occupied then "occupied" else "available"
  in
    li [ class ("seat " ++ occupiedClass), onClick address seat ] [ text (toString seat.seatNo) ]


-- PORTS

port seats : Signal Model


port reserveSeat : Signal Int


port updateSeat : Signal Seat
port updateSeat =
  seatsToUpdate.signal


-- SIGNALS

actions : Signal Action
actions =
  Signal.merge addSeats seatReservations


addSeats : Signal Action
addSeats =
  Signal.map AddSeats seats


seatsToUpdate : Signal.Mailbox Seat
seatsToUpdate =
  Signal.mailbox (Seat 0 False)


seatReservations : Signal Action
seatReservations =
  Signal.map (\seatNo -> Reserve seatNo) reserveSeat


model : Signal Model
model =
  Signal.foldp update initialModel actions


main =
  Signal.map (view seatsToUpdate.address) model
