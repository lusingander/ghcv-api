module Main where

import Prelude
import Data.Bitraversable (bitraverse)
import Data.Either (Either)
import Data.Either (note) as Either
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
    liftEffect $ bitraverse startFail startServer config

startServer :: Config -> HTTPure.ServerM
startServer _ = HTTPure.serve 8080 router $ Console.log "Server now up on http://localhost:8080"

startFail :: String -> Effect Unit
startFail e = Console.log $ "Failed to start: " <> e

type Config
  = { token :: String }

loadConfig :: Aff (Either String Config)
loadConfig = do
  _ <- Dotenv.loadFile
  liftEffect loadConfig'

loadConfig' :: Effect (Either String Config)
loadConfig' = do
  maybeToken <- lookupEnv configKeyToken
  let
    config = do
      token <- Either.note "token is not set" maybeToken
      pure { token: token }
  pure config

configKeyToken :: String
configKeyToken = "GITHUB_API_TOKEN"

router :: HTTPure.Request -> HTTPure.ResponseM
router { method: HTTPure.Get, path: [ userId ] } = HTTPure.ok userId

router { method: HTTPure.Get, path: [ userId, "prs" ] } = HTTPure.ok userId

router _ = HTTPure.notFound
