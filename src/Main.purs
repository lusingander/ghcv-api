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
startServer config = HTTPure.serve config.port (router config) $ startSuccess config

startSuccess :: Config -> Effect Unit
startSuccess config = Console.log $ "Server now up on http://localhost:" <> show config.port

startFail :: String -> Effect Unit
startFail e = Console.log $ "Failed to start: " <> e

router :: Config -> HTTPure.Request -> HTTPure.ResponseM
router = responseMiddleware <<< router'

router' :: Config -> HTTPure.Request -> HTTPure.ResponseM
router' _ { method: HTTPure.Get, path: [] } = HTTPure.ok "ok"

router' config { method: HTTPure.Get, path: [ "users", userId ] } = handleUser config userId

router' config { method: HTTPure.Get, path: [ "users", userId, "prs" ] } = handleUserPrs config userId

router' _ _ = HTTPure.notFound

responseMiddleware :: (HTTPure.Request -> HTTPure.ResponseM) -> HTTPure.Request -> HTTPure.ResponseM
responseMiddleware rt req = do
  response@{ headers } <- rt req
  pure $ response { headers = header <> headers }
  where
  header = HTTPure.header "Access-Control-Allow-Origin" "*" -- fixme
