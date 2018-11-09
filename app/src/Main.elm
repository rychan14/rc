module Main exposing (main)

import Browser exposing (Document)
import Css exposing (..)
import Css.Global exposing (global, everything, body)
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attributes
import Html.Styled.Events exposing (..)
import Http
import Json.Decode as Decode
import Url.Builder as Url
import Random

main =
  Browser.document
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

-- Model

type alias Model = 
  { city : String
  , temp : Maybe Float
  , apiKey: String
  }

type alias Config =
  { apiKey : String
  }

init : Config -> (Model, Cmd Msg)
init flags =
  ( Model "" Nothing flags.apiKey
  , Cmd.none
  )

-- Update

type Msg
    = GrabData
    | NewData (Result Http.Error Float)
    | NewCity String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GrabData ->
      ( model
      , getData model
      )
    
    NewData result -> 
      case result of
        Ok newTemp -> 
          ( { model | temp = Just newTemp }
          , Cmd.none
          )

        Err _ ->
          ( model
          , Cmd.none
          )
    
    NewCity newCity ->
      ( { model | city = newCity }
      , Cmd.none
      )

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- View
-- #FFF
-- #90AFC5
-- #336B87
-- #2A3132
-- #763626

btn : List (Attribute Msg) -> List (Html Msg) -> Html Msg
btn =
  styled button
    [ property "all" "unset"
    , border3 (px 2) solid (hex "2a3132")
    , borderRadius (px 2)
    , color (hex "2a3132")
    , cursor pointer
    , margin (px 12)
    , outline none
    , padding2 (px 5) (px 10)
    , hover
      [ backgroundColor (hex "2a3132")
      , color (hex "fff")
      ]
    ]

txt : List (Attribute Msg) -> List (Html Msg) -> Html Msg
txt =
  styled input
    [ property "all" "unset"
    , borderBottom3 (px 1) solid (hex "2a3132")
    , active
      [ borderBottom3 (px 1) solid (hex "90afc5")
      ]
    , focus
      [ borderBottom3 (px 1) solid (hex "90afc5")
      ]
    ]

modelTxt =
  styled h1
    [ color (hex "336b87") ]

-- UI Components

globalStyle = 
  global
    [ everything 
      [ boxSizing borderBox
      , fontFamilies [ "Verdana" ]
      ]
    , body
      [ backgroundColor (hex "e5e5e5")
      , margin (px 0)
      , overflow hidden
      ]
    ]

container = 
  styled div 
    [ overflow auto
    , padding (px 10)
    , width (vw 100)
    ]

navi =
  styled div
    [ backgroundColor (hex "2A3132")
    , bottom (px 0)
    , height (vw 100)
    , maxWidth (px 100)
    , position fixed
    , right (px 0)
    , top (px 0)
    , width (vw 20)
    ]

view : Model -> Document Msg
view model =
  { title = "RC"
  , body = List.map toUnstyled
    [ globalStyle
    , container [] 
      [ txt 
        [ onInput NewCity
        , Attributes.value model.city
        ]
        []
      , div []
        [ p [] [ text "Temperature" ]
        , modelTxt [] 
          [ text
            ( case model.temp of
              Just value -> String.fromFloat value
              Nothing -> ""
            )
          ]
        ]
      , btn [ onClick GrabData ] [ text "Grab Data!" ]
      ]
    ]
  }

-- Http

getData : Model -> Cmd Msg
getData model =
  Http.send NewData (Http.get (toUrl model.city model.apiKey) weatherDecoder)

toUrl : String -> String -> String
-- toUrl subject apiKey =
--   Url.crossOrigin 
--     "http://api.openweathermap.org"
--     [ "data", "2.5", "weather" ]
--     [ Url.string "APPID" apiKey
--     , Url.string "q" subject
--     ]
toUrl subject apiKey =
  Url.relative
    [ "api", "data" ]
    []

weatherDecoder : Decode.Decoder Float
-- weatherDecoder =
--   Decode.field "main" (Decode.field "temp" Decode.float)

weatherDecoder =
  Decode.field "temp" Decode.float