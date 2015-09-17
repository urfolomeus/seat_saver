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

type Action = NoOp | AddSeats Model


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model
    AddSeats seats ->
      seats


-- VIEW

view : Signal.Address Seat -> Model -> Html
view address model =
  ul [ ] ( List.map (seatItem address) model )


seatItem : Signal.Address Seat -> Seat -> Html
seatItem address seat =
  li [ onClick address seat ] [ text (toString seat) ]


-- PORTS

port seats : Signal Model


port updateSeat : Signal Seat
port updateSeat =
  seatsToUpdate.signal


-- SIGNALS

actions : Signal Action
actions =
  addSeats


addSeats : Signal Action
addSeats =
  Signal.map AddSeats seats


seatsToUpdate : Signal.Mailbox Seat
seatsToUpdate =
  Signal.mailbox (Seat 0 False)


model : Signal Model
model =
  Signal.foldp update initialModel actions


main =
  Signal.map (view seatsToUpdate.address) model
