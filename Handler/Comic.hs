{-# LANGUAGE TupleSections, OverloadedStrings #-}
module Handler.Comic where

import Import
import Text.Coffee

getComicR :: Handler RepHtml
getComicR = do
    let handlerName = "getComicR" :: Text
    defaultLayout $ do
        aDomId <- lift newIdent
        setTitle "Rain - Comic"
        toWidget $(coffeeFile "templates/comic.coffee")
        $(widgetFile "comic")

