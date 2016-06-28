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

import Tag

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http exposing (..)
import Task
import Json.Decode
import Json.Encode

main =
  Html.program {
    init = init,
    view = view,
    update = update,
    subscriptions = subscriptions
  }


-- MODEL

type alias Model =
  { name : String
  , editName : String
  -- , path : List String
  , errMsg : String
  , id : String
  }

init : (Model, Cmd Msg)
init =
  (Model "blue" -- [ "color" ]
   "" "" "", Cmd.none) -- getRandomGif "cats")


-- UPDATE

type Msg = Create
  | EditName String
  --| SelectTopic String
  --| ChangeTopic String
  | CreateSucceed String
  | CreateFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Create ->
      ({ model | errMsg = "(creating tag ...)" }, createTag model.name)

    EditName newName ->
      ({ model | editName = newName, errMsg = "" }, Cmd.none)

--    SelectTopic newTopic ->
--      ({ model | selectTopic = newTopic, topic = newTopic, errMsg = "" }, getRandomGif newTopic)

--    ChangeTopic newTopic ->
--      ({ model | topic = newTopic, editTopic = "", errMsg = "(changed topic)" }, getRandomGif newTopic)

    CreateSucceed newId ->
      ({ model | id = newId, errMsg = "(created tag " ++ newId ++ ")" }, Cmd.none)

    CreateFail err ->
        ({ model | errMsg = "!! FAILED to create tag !! " ++ (toString err) }, Cmd.none)

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


createTag : String -> Cmd Msg
createTag tagName =
  let
    url =
--      "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
      "http://localhost:33333/api/tags" -- ++ tagName
    bodyObj =
      Json.Encode.object
        [ ("name", Json.Encode.string tagName ) ]
    bodyStr = Json.Encode.encode 2 bodyObj
  in
{--
--    Task.perform FetchFail FetchSucceed (Http.get decodeGifUrl url)
--    Task.perform CreateFail CreateSucceed (Http.getString url)
--    Task.perform CreateFail CreateSucceed (Http.post ( -- Json.Decode.list
--                                                      Json.Decode.string) url (Http.string (Json.Encode.encode 2 bodyObj)))
--}
    Task.perform CreateFail CreateSucceed (Http.post ( Json.Decode.at ["id"] Json.Decode.string
                                                     ) url (Http.string bodyStr))


{--
postJson : Json.Decoder value -> String -> Body -> Task Error value
postJson decoder url body =
  let request =
        { verb = "POST"
        , headers = []
        , url = url
        , body = body
        }
  in
      fromJson decoder (send defaultSettings request)
--}


{--
-- import Json.Decode (list, string)

--hats : Task Error (List String)
--hats =
--    post (list string) "http://example.com/hat-categories.json" empty

--person =
--    object
--      [ ("name", string "Tom")
--      , ("age", int 42)
--      ]

--compact = encode 0 person
---- {"name":"Tom","age":42}



decodeGifUrl : Json.Decode.Decoder String
decodeGifUrl =
  Json.Decode.at ["data", "image_url"] Json.Decode.string
--}


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ h2 [] [text ("Tag " ++ model.name)]
    , table [] [
        tr [] [ td [] [ label [] [ text "tag:" ] ]
        , td [] [ input [type' "text", value model.editName, onInput EditName ] [] ] ]
      , tr [] [ td [] [ -- img [src model.gifUrl] []
                --,
                        button [ onClick Create ] [ text "Create" ] ] ]
--      ,
--      tr [] [ td []
--        [ select []
--          [ option [ onClick (SelectTopic "cats") ] [ text "cats" ]
--          , option [ onClick (SelectTopic "dogs") ] [ text "dogs" ]
--          ]
--        , input [type' "text", -- name "topicText",
--                 value model.editTopic, onInput EditTopic ] []
----        , button [ onClick (ChangeTopic model.tmpTopic) ] [ text "Change Topic" ]
--        , button [ onClick (changeTopic model) ] [ text "Change Topic" ]
--        ] ]
--      ,
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

--changeTopic model =
--  if model.editTopic == "" || model.editTopic == model.topic
--    then ChangeTopic model.selectTopic
--    else ChangeTopic model.editTopic

--  if model.topic == model.editTopic
--    then ChangeTopic model.selectTopic
--    else if model.editTopic != ""
--     ChangeTopic model.editTopic


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


