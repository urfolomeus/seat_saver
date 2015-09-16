module SeatSaver where

import Html exposing (..)
import Html.Attributes exposing (..)


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

view : Model -> Html
view model =
  ul [ ] ( List.map seatItem model )


seatItem : Seat -> Html
seatItem seat =
  li [ ] [ text (toString seat) ]


-- PORTS

port seats : Signal Model


-- SIGNALS

actions : Signal Action
actions =
  addSeats


addSeats : Signal Action
addSeats =
  Signal.map AddSeats seats


model : Signal Model
model =
  Signal.foldp update initialModel actions


main =
  Signal.map view model
