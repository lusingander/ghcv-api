module Pr
  ( list
  , Response
  , Edge
  , Node
  , Repository
  ) where

import Prelude
import Data.Maybe (Maybe)
import Effect.Aff (Aff)
import Gh as Gh
import Util as Util

prNumPerReq :: Int
prNumPerReq = 50

type Response
  = { search ::
        { issueCount :: Int
        , edges :: Array Edge
        }
    }

type Edge
  = { cursor :: String
    , node :: Node
    }

type Node
  = { title :: String
    , state :: String
    , number :: Int
    , url :: String
    , additions :: Int
    , deletions :: Int
    , comments ::
        { totalCount :: Int
        }
    , reviews ::
        { totalCount :: Int
        }
    , createdAt :: String
    , closedAt :: Maybe String
    , repository :: Repository
    }

type Repository
  = { name :: String
    , description :: Maybe String
    , owner ::
        { login :: String
        }
    , primaryLanguage ::
        Maybe
          { name :: String
          , color :: Maybe String
          }
    , stargazers ::
        { totalCount :: Int
        }
    , watchers ::
        { totalCount :: Int
        }
    , forkCount :: Int
    }

list :: String -> Gh.Token -> Aff (Gh.GhResult Response)
list userId =
  Gh.post
    $ Util.formatQuery query
        [ { marker: "__authorId__", value: userId }
        , { marker: "__excludeUserId__", value: userId }
        , { marker: "__first__", value: show prNumPerReq }
        ]

query :: String
query =
  """
query { 
  search(query: \"author:__authorId__ -user:__excludeUserId__ is:pr sort:created-desc\", type: ISSUE, first: __first__, after: null) {
    issueCount
    edges {
      cursor
      node {
        ... on PullRequest {
          title
          state
          number
          url
          additions
          deletions
          comments {
            totalCount
          }
          reviews {
            totalCount
          }
          createdAt
          closedAt
          repository {
            name
            description
            owner {
              login
            }
            primaryLanguage {
              name
              color
            }
            stargazers {
              totalCount
            }
            watchers {
              totalCount
            }
            forkCount
          }
        }
      }
    }
  }
}"""
