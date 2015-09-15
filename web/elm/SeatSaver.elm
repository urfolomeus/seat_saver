module SeatSaver where

import Html exposing (..)
import Html.Attributes exposing (..)


main =
  view initialModel


-- MODEL

type alias Seat =
  { seatNo : Int
  , occupied : Bool
  }


type alias Model =
  List Seat


initialModel : Model
initialModel =
  [ {seatNo = 1, occupied = True}, {seatNo = 2, occupied = False} ]


-- VIEW

view : (List Seat) -> Html
view model =
  ul [ ] ( List.map seatItem model )


seatItem : Seat -> Html
seatItem seat =
  li [ ] [ text (toString seat) ]
