
module Handler.Data where

import Import

--getDataR :: Handler RepJson
getDataR :: String -> Handler RepHtmlJson
getDataR contentId = do
    let handlerName = "getDataR" :: Text
    let name = "name" :: Text
    let widget = do
            setTitle $ toHtml name
            [whamlet|Looks like you have Javascript off. Name: #{name}|]
    let json = object [ "id" .= contentId
                      , "name" .= ( "All Good Comics" :: Text )
                      , "pages" .= ( [ "http://digitalcomicmuseum.com/preview/cache/1361532049All%20Good%20Comics%201-01.jpg" ] :: [ Text ] )
                      ]
    defaultLayoutJson widget json
    --jsonToRepJson json
