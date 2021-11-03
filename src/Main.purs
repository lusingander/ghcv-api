module Main where

import Prelude
import Data.Array as Array
import Effect.Console as Console
import HTTPure ((!@))
import HTTPure as HTTPure

main :: HTTPure.ServerM
main = HTTPure.serve 8080 router $ Console.log "Server now up on http://localhost:8080"

router :: HTTPure.Request -> HTTPure.ResponseM
router { method: HTTPure.Get, path }
  | matchUserPath path = handleUserPath $ parseUserPath path
  | matchUserPrPath path = handleUserPrPath $ parseUserPrPath path
  | otherwise = HTTPure.notFound

router _ = HTTPure.notFound

-- /{user}
matchUserPath :: HTTPure.Path -> Boolean
matchUserPath path = Array.length path == 1

parseUserPath :: HTTPure.Path -> String
parseUserPath path = path !@ 0

handleUserPath :: String -> HTTPure.ResponseM
handleUserPath user = HTTPure.ok user

-- /{user}/prs
matchUserPrPath :: HTTPure.Path -> Boolean
matchUserPrPath path = Array.length path == 2 && path !@ 1 == "prs"

parseUserPrPath :: HTTPure.Path -> String
parseUserPrPath path = path !@ 0

handleUserPrPath :: String -> HTTPure.ResponseM
handleUserPrPath user = HTTPure.ok user
