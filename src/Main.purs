module Main where

import Prelude
import Data.Maybe (fromMaybe)
import Dotenv (loadFile) as Dotenv
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console as Console
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
router { method: HTTPure.Get, path: [ userId ] } = HTTPure.ok userId

router { method: HTTPure.Get, path: [ userId, "prs" ] } = HTTPure.ok userId

router _ = HTTPure.notFound
