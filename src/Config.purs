module Config
  ( Config
  , loadConfig
  ) where

import Prelude
import Data.Either (Either)
import Data.Either (note) as Either
import Data.Int as Int
import Dotenv (loadFile) as Dotenv
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Node.Process (lookupEnv)

type Config
  = { port :: Int
    , token :: String
    }

loadConfig :: Aff (Either String Config)
loadConfig = do
  _ <- Dotenv.loadFile
  liftEffect loadConfig'

loadConfig' :: Effect (Either String Config)
loadConfig' = do
  maybePort <- lookupEnv configKeyPort
  maybeToken <- lookupEnv configKeyToken
  let
    config = do
      port <- Either.note "port is not set" $ Int.fromString =<< maybePort
      token <- Either.note "token is not set" maybeToken
      pure { port: port, token: token }
  pure config

configKeyPort :: String
configKeyPort = "PORT"

configKeyToken :: String
configKeyToken = "GITHUB_API_TOKEN"
