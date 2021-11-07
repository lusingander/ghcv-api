module Handler
  ( handleUser
  , handleUserPrs
  ) where

import Prelude
import Config (Config)
import Data.Either (Either(..))
import Data.Nullable (Nullable, toNullable)
import Gh (GhResponse(..), GhResult, StatusCode) as Gh
import HTTPure as HTTPure
import Pr (Node, Response, Repository, list) as Pr
import Simple.JSON (writeJSON)
import User (Response, detail) as User
import Util (groupBy, mapToArray, validGhUserId)

githubBaseUrl :: String
githubBaseUrl = "https://github.com/"

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
handleUser config userId = case validGhUserId userId of
  Left e -> HTTPure.badRequest e
  Right _ -> do
    result <- User.detail userId config.token
    handleGhResult result $ HTTPure.ok <<< writeJSON <<< toUserResponse

type UserPrsResponse
  = { totalCount :: Int
    , owners :: Array UserPrsOwnerResponse
    }

type UserPrsOwnerResponse
  = { name :: String
    , repositories :: Array UserPrsRepositoryResponse
    }

type UserPrsRepositoryResponse
  = { name :: String
    , description :: Nullable String
    , url :: String
    , watchers :: Int
    , stars :: Int
    , forks :: Int
    , langName :: Nullable String
    , langColor :: Nullable String
    , pullRequests :: Array UserPrsPullRequestResponse
    }

type UserPrsPullRequestResponse
  = { title :: String
    , state :: String
    , number :: Int
    , url :: String
    , additions :: Int
    , deletions :: Int
    , comments :: Int
    , createdAt :: String
    , closedAt :: Nullable String
    }

toUserPrsResponse :: Pr.Response -> UserPrsResponse
toUserPrsResponse res =
  { totalCount: res.search.issueCount
  , owners: toUserPrsOwnerResponses res
  }

toUserPrsOwnerResponses :: Pr.Response -> Array UserPrsOwnerResponse
toUserPrsOwnerResponses res = map (\e -> toUserPrsOwnerResponse e.key e.value) $ mapToArray nodesMap
  where
  nodesMap = groupBy _.repository.owner.login $ map _.node res.search.edges

toUserPrsOwnerResponse :: String -> Array Pr.Node -> UserPrsOwnerResponse
toUserPrsOwnerResponse owner nodes =
  { name: owner
  , repositories: toUserPrsRepositoryResponses nodes
  }

toUserPrsRepositoryResponses :: Array Pr.Node -> Array UserPrsRepositoryResponse
toUserPrsRepositoryResponses nodes = map (\e -> toUserPrsRepositoryResponse e.key e.value) $ mapToArray nodesMap
  where
  nodesMap = groupBy _.repository nodes

toUserPrsRepositoryResponse :: Pr.Repository -> Array Pr.Node -> UserPrsRepositoryResponse
toUserPrsRepositoryResponse repo nodes =
  { name: repo.name
  , description: toNullable repo.description
  , url: url
  , watchers: repo.watchers.totalCount
  , stars: repo.stargazers.totalCount
  , forks: repo.forkCount
  , langName: toNullable $ map _.name repo.primaryLanguage
  , langColor: toNullable $ bind repo.primaryLanguage _.color
  , pullRequests: map toUserPrsPullRequestResponse nodes
  }
  where
  url = githubBaseUrl <> repo.owner.login <> "/" <> repo.name

toUserPrsPullRequestResponse :: Pr.Node -> UserPrsPullRequestResponse
toUserPrsPullRequestResponse node =
  { title: node.title
  , state: node.state
  , number: node.number
  , url: node.url
  , additions: node.additions
  , deletions: node.deletions
  , comments: node.comments.totalCount
  , createdAt: node.createdAt
  , closedAt: toNullable node.closedAt
  }

handleUserPrs :: Config -> String -> HTTPure.ResponseM
handleUserPrs config userId = case validGhUserId userId of
  Left e -> HTTPure.badRequest e
  Right _ -> do
    result <- Pr.list userId config.token
    handleGhResult result $ HTTPure.ok <<< writeJSON <<< toUserPrsResponse

handleGhResult :: forall a. Gh.GhResult a -> (a -> HTTPure.ResponseM) -> HTTPure.ResponseM
handleGhResult result handler = case result of
  Right r -> handleGhResponse r handler
  Left e -> HTTPure.internalServerError e

handleGhResponse :: forall a. { statusCode :: Gh.StatusCode, response :: Gh.GhResponse a } -> (a -> HTTPure.ResponseM) -> HTTPure.ResponseM
handleGhResponse { statusCode: statusCode, response: response } handler = case response of
  Gh.Ok res -> handler res.data
  Gh.GraphError res -> HTTPure.badRequest $ "graph error: " <> show res
  Gh.RequestError res -> HTTPure.response statusCode $ "request error: " <> show res
