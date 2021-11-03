module Main where

import Prelude
import Data.Array as Array
import Data.Maybe (fromMaybe)
import Dotenv (loadFile) as Dotenv
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console as Console
import HTTPure ((!@))
import HTTPure as HTTPure
import Node.Process (lookupEnv)

main :: Effect Unit
main =
  launchAff_ do
    config <- loadConfig
    liftEffect $ HTTPure.serve 8080 router $ Console.log "Server now up on http://localhost:8080"

type Config
  = { token :: String }

loadConfig :: Aff Config
loadConfig = do
  _ <- Dotenv.loadFile
  liftEffect loadConfig'

loadConfig' :: Effect Config
loadConfig' = do
  maybeToken <- lookupEnv configKeyToken
  let
    token = fromMaybe "invalid" maybeToken
  pure { token: token }

configKeyToken :: String
configKeyToken = "GITHUB_API_TOKEN"

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
