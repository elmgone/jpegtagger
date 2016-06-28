-- Copyright © 2016 ElmGone mrcs.elmgone@mailnull.com
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http exposing (..)
import Task
import Json.Decode

main =
  Html.program {
    init = init,
    view = view,
    update = update,
    subscriptions = subscriptions
  }


-- MODEL

type alias Model =
  { topic : String
  , editTopic : String
  , selectTopic : String
  , gifUrl : String
  , errMsg : String
  }

init : (Model, Cmd Msg)
init =
--  ({ topic = "cats", gifUrl = "waiting.gif" }, Cmd.none)
  (Model "cats" "" "cats" "waiting.gif" "", getRandomGif "cats")


-- UPDATE

type Msg = MorePlease
  | EditTopic String
  | SelectTopic String
  | ChangeTopic String
  | FetchSucceed String
  | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      ({ model | errMsg = "(fetching gif ...)" }, getRandomGif model.topic)

    EditTopic newTopic ->
      ({ model | editTopic = newTopic, errMsg = "" }, Cmd.none)

    SelectTopic newTopic ->
      ({ model | selectTopic = newTopic, topic = newTopic, errMsg = "" }, getRandomGif newTopic)

    ChangeTopic newTopic ->
      ({ model | topic = newTopic, editTopic = "", errMsg = "(changed topic)" }, getRandomGif newTopic)

    FetchSucceed newUrl ->
      ({ model | gifUrl = newUrl, errMsg = "(got gif)" }, Cmd.none)

    FetchFail err ->
        ({ model | errMsg = "!! FAILED to fetch gif !! " ++ (toString err) }, Cmd.none)
--      (Model model.topic model.gifUrl (toString error), Cmd.none)
--      ({ model | errMsg = "!! FAILED to fetch gif !!" }, Cmd.none)
--
--      case err of
--        Http.Timeout ->
--          ({ model | errMsg = "!! FAILED to fetch gif : TIMEOUT !!" }, Cmd.none)
--
--        Http.NetworkError ->
--          ({ model | errMsg = "!! FAILED to fetch gif : NetworkError !!" }, Cmd.none)
--
--        Http.UnexpectedPayload errMsg ->
--          ({ model | errMsg = "!! FAILED to fetch gif : UnexpectedPayload : " ++ errMsg }, Cmd.none)
--
--        Http.BadResponse errStatus errMsg ->
--          ({ model | errMsg = "!! FAILED to fetch gif : BadResponse : " ++ errMsg }, Cmd.none)


getRandomGif : String -> Cmd Msg
getRandomGif topic =
  let
    url =
--      "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
      "http://localhost:33333/cors/api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
  in
    Task.perform FetchFail FetchSucceed (Http.get decodeGifUrl url)
--    Task.perform FetchFail FetchSucceed (Http.getString url)

decodeGifUrl : Json.Decode.Decoder String
decodeGifUrl =
  Json.Decode.at ["data", "image_url"] Json.Decode.string


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ h2 [] [text ("Fun with " ++ model.topic)]
    , table [] [ tr [] [ td [] [ img [src model.gifUrl] []
        , button [ onClick MorePlease ] [ text "More Please!" ]
        ] ]
      , tr [] [ td []
        [ select []
          [ option [ onClick (SelectTopic "cats") ] [ text "cats" ]
          , option [ onClick (SelectTopic "dogs") ] [ text "dogs" ]
          ]
        , input [type' "text", -- name "topicText",
                 value model.editTopic, onInput EditTopic ] []
--        , button [ onClick (ChangeTopic model.tmpTopic) ] [ text "Change Topic" ]
        , button [ onClick (changeTopic model) ] [ text "Change Topic" ]
        ] ]
      , tr [] [ td [] [ text model.errMsg ] ]
      ]
--    , select [] [ option [ onClick (ChangeTopic "cats") ] [ text "cats" ]
--      , option [ onClick (ChangeTopic "dogs") ] [text "dogs" ]
--      ]
--    , menu [] [ menuitem [] [ text "menu action 1" , text "menu action 2"] ]

--    , img [src model.gifUrl] []
--    , input [type' "text", name "topicText", value model.tmpTopic, onInput EditTopic ] []
--    , button [ onClick (ChangeTopic model.tmpTopic) ] [ text "Change Topic" ]
--    , button [ onClick MorePlease ] [ text "More Please!" ]
--    , text model.errMsg
    ]

changeTopic model =
  if model.editTopic == "" || model.editTopic == model.topic
    then ChangeTopic model.selectTopic
    else ChangeTopic model.editTopic
--  if model.topic == model.editTopic
--    then ChangeTopic model.selectTopic
--    else if model.editTopic != ""
--     ChangeTopic model.editTopic


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

