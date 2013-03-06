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
        addScriptRemote "/static/js/jquery-2.0.0b2.js"
        addScriptRemote "/static/js/jquery.mobile-1.3.0.js"
        addScriptRemote "/static/js/coffee-script-1.4.0.min.js"
        addScriptRemote "/static/js/coffeetable-0.3.0.js"
        addScriptRemote "/static/js/underscore-1.4.4.js"
        addScriptRemote "/static/js/backbone-0.9.10.js"
        toWidget $(coffeeFileReload "templates/comic.coffee")

