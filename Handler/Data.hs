
module Handler.Data where

import Import

--getDataR :: Handler RepJson
getDataR :: Handler RepHtmlJson
getDataR = do
    let handlerName = "getDataR" :: Text
    let name = "name" :: Text
    let widget = do
            setTitle $ toHtml name
            [whamlet|Looks like you have Javascript off. Name: #{name}|]
    let json = object [ "id" .= ( "v01-c01.json" :: Text )
                      , "name" .= ( "wild-cats" :: Text )
                      , "cover" .= ( "static/img/wild-cats/v01/c01/cover.jpg" :: Text )
                      ]
    defaultLayoutJson widget json
    --jsonToRepJson json
