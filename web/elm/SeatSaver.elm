module SeatSaver where

import Html exposing (..)
import Html.Attributes exposing (..)


main =
  view


view =
  div [ class "jumbotron" ]
    [ h2 [ ] [ text "Hello from Elm!" ]
    , p [ class "lead" ]
      [ text "the best of functional programming in your browser" ]
    ]
