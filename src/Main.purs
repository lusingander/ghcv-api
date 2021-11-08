module Main where

import Prelude
import Config (Config, loadConfig)
import Data.Bitraversable (bitraverse)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console as Console
import HTTPure as HTTPure
import Handler (handleUser, handleUserPrs)

main :: Effect Unit
main =
  launchAff_ do
    config <- loadConfig
    liftEffect $ bitraverse startFail startServer config

startServer :: Config -> HTTPure.ServerM
startServer config = HTTPure.serve config.port (router config) $ Console.log $ "Server now up on http://localhost:" <> show config.port

startFail :: String -> Effect Unit
startFail e = Console.log $ "Failed to start: " <> e

router :: Config -> HTTPure.Request -> HTTPure.ResponseM
router config { method: HTTPure.Get, path: [ "users", userId ] } = handleUser config userId

router config { method: HTTPure.Get, path: [ "users", userId, "prs" ] } = handleUserPrs config userId

router _ _ = HTTPure.notFound
