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
  port <- loadPort
  token <- loadToken
  pure $ { port: _, token: _ } <$> port <*> token

loadPort :: Effect (Either String Int)
loadPort = do
  maybePort <- lookupEnv configKeyPort
  pure $ Either.note "port is not set" $ Int.fromString =<< maybePort

loadToken :: Effect (Either String String)
loadToken = do
  maybeToken <- lookupEnv configKeyToken
  pure $ Either.note "token is not set" maybeToken

configKeyPort :: String
configKeyPort = "PORT"

configKeyToken :: String
configKeyToken = "GITHUB_API_TOKEN"
