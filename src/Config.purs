module Config
  ( Config
  , loadConfig
  ) where

import Prelude
import Data.Either (Either)
import Data.Either (note) as Either
import Dotenv (loadFile) as Dotenv
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Node.Process (lookupEnv)

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
