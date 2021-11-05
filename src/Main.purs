module Main where

import Prelude
import Data.Bitraversable (bitraverse)
import Data.Either (Either(..))
import Data.Either (note) as Either
import Dotenv (loadFile) as Dotenv
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console as Console
import Gh (GhResponse(..)) as Gh
import HTTPure as HTTPure
import Node.Process (lookupEnv)
import User (user) as User

main :: Effect Unit
main =
  launchAff_ do
    config <- loadConfig
    liftEffect $ bitraverse startFail startServer config

startServer :: Config -> HTTPure.ServerM
startServer config = HTTPure.serve 8080 (router config) $ Console.log "Server now up on http://localhost:8080"

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

router :: Config -> HTTPure.Request -> HTTPure.ResponseM
router config { method: HTTPure.Get, path: [ "users", userId ] } = handleUser config userId

router _ { method: HTTPure.Get, path: [ "users", userId, "prs" ] } = HTTPure.ok userId

router _ _ = HTTPure.notFound

handleUser :: Config -> String -> HTTPure.ResponseM
handleUser config userId = do
  result <- User.user userId config.token
  liftEffect
    $ case result of
        Left e -> Console.log e
        Right r ->
          Console.log
            $ case r of
                Gh.Ok d -> show d
                Gh.Error e -> show e
  HTTPure.ok userId
