module User
  ( detail
  , Response
  ) where

import Prelude
import Data.Maybe (Maybe)
import Effect.Aff (Aff)
import Gh as Gh
import Util as Util

type Response
  = { user ::
        { login :: String
        , name :: Maybe String
        , location :: Maybe String
        , company :: Maybe String
        , websiteUrl :: Maybe String
        , avatarUrl :: String
        }
    }

detail :: String -> Gh.Token -> Aff (Gh.GhResult Response)
detail userId = Gh.post $ Util.formatQuery query [ { marker: "__userId__", value: userId } ]

query :: String
query =
  """
query { 
  user(login: \"__userId__\") {
    login
    name
    location
    company
    websiteUrl
    avatarUrl
  }
}"""
