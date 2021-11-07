module Handler
  ( handleUser
  ) where

import Prelude
import Config (Config)
import Data.Either (Either(..))
import Data.Nullable (Nullable, toNullable)
import Gh (GhResponse(..), GhResult, StatusCode) as Gh
import HTTPure as HTTPure
import Simple.JSON (writeJSON)
import User (Response, detail) as User

type UserResponse
  = { login :: String
    , name :: Nullable String
    , location :: Nullable String
    , company :: Nullable String
    , websiteUrl :: Nullable String
    , avatarUrl :: String
    }

toUserResponse :: User.Response -> UserResponse
toUserResponse res =
  { login: res.user.login
  , name: toNullable res.user.name
  , location: toNullable res.user.location
  , company: toNullable res.user.company
  , websiteUrl: toNullable res.user.websiteUrl
  , avatarUrl: res.user.avatarUrl
  }

handleUser :: Config -> String -> HTTPure.ResponseM
handleUser config userId = do
  result <- User.detail userId config.token
  handleGhResult result $ HTTPure.ok <<< writeJSON <<< toUserResponse

handleGhResult :: forall a. Gh.GhResult a -> (a -> HTTPure.ResponseM) -> HTTPure.ResponseM
handleGhResult result handler = case result of
  Right r -> handleGhResponse r handler
  Left e -> HTTPure.internalServerError e

handleGhResponse :: forall a. { statusCode :: Gh.StatusCode, response :: Gh.GhResponse a } -> (a -> HTTPure.ResponseM) -> HTTPure.ResponseM
handleGhResponse { statusCode: statusCode, response: response } handler = case response of
  Gh.Ok res -> handler res.data
  Gh.GraphError res -> HTTPure.badRequest $ "graph error: " <> show res
  Gh.RequestError res -> HTTPure.response statusCode $ "request error: " <> show res
