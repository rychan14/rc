module Main exposing (main)

import Browser exposing (Document)
import Css exposing (..)
import Css.Global exposing (global, everything)
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
  , temp : Float
  , apiKey: String
  }

type alias Config =
  { apiKey : String
  }

init : Config -> (Model, Cmd Msg)
init flags =
  ( Model "" 0.0 flags.apiKey
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
          ( { model | temp = newTemp }
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
btn : List (Attribute Msg) -> List (Html Msg) -> Html Msg
btn =
  styled button
    [ property "all" "unset"
    , border3 (px 2) solid (hex "55af6a")
    , borderRadius (px 2)
    , color (hex "55af6a")
    , cursor pointer
    , margin (px 12)
    , outline none
    , padding2 (px 5) (px 10)
    , property "user-select" "none"
    , hover
      [ backgroundColor (hex "55af6a")
      , color (hex "fff")
      ]
    ]

txt : List (Attribute Msg) -> List (Html Msg) -> Html Msg
txt =
  styled input
    [ property "all" "unset"
    , borderBottom3 (px 1) solid (hex "000")
    ]

modelTxt =
  styled h1
    []

globalStyle = 
  global
    [ everything 
      [ fontFamilies [ "Verdana" ]
      ]
    ]

view : Model -> Document Msg
view model =
  { title = "RC"
  , body = List.map toUnstyled
    [ globalStyle
    , txt 
      [ onInput NewCity
      , Attributes.value model.city
      ]
      []
    , modelTxt [] [ text (String.fromFloat model.temp) ]
    , btn [ onClick GrabData ] [ text "Grab Data!" ]
    ]
  }
  
-- Http

getData : Model -> Cmd Msg
getData model =
  Http.send NewData (Http.get (toUrl model.city model.apiKey) weatherDecoder)

toUrl : String -> String -> String
toUrl subject apiKey =
  Url.crossOrigin 
    "http://api.openweathermap.org"
    [ "data", "2.5", "weather" ]
    [ Url.string "APPID" apiKey
    , Url.string "q" subject
    ]

weatherDecoder : Decode.Decoder Float
weatherDecoder =
  Decode.field "main" (Decode.field "temp" Decode.float)
