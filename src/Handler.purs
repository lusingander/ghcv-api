module Handler
  ( handleUser
  ) where

import Prelude
import Config (Config)
import Data.Either (Either(..))
import Gh (GhResponse(..), GhResult, StatusCode) as Gh
import HTTPure as HTTPure
import User (user) as User

handleUser :: Config -> String -> HTTPure.ResponseM
handleUser config userId = do
  result <- User.user userId config.token
  handleGhResult result (\u -> HTTPure.ok u.user.avatarUrl)

handleGhResult :: forall a. Gh.GhResult a -> (a -> HTTPure.ResponseM) -> HTTPure.ResponseM
handleGhResult result handler = case result of
  Right r -> handleGhResponse r handler
  Left e -> HTTPure.internalServerError e

handleGhResponse :: forall a. { statusCode :: Gh.StatusCode, response :: Gh.GhResponse a } -> (a -> HTTPure.ResponseM) -> HTTPure.ResponseM
handleGhResponse { statusCode: statusCode, response: response } handler = case response of
  Gh.Ok res -> handler res.data
  Gh.GraphError res -> HTTPure.badRequest $ "graph error: " <> show res
  Gh.RequestError res -> HTTPure.response statusCode $ "request error: " <> show res
