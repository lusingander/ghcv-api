module User
  ( detail
  , Response
  ) where

import Prelude
import Data.Maybe (Maybe)
import Data.String (Pattern(..), Replacement(..))
import Data.String (replace, replaceAll) as String
import Effect.Aff (Aff)
import Gh as Gh

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
detail userId = Gh.post $ buildQuery userId

buildQuery :: String -> String
buildQuery userId = String.replace (Pattern "__userId__") (Replacement userId) queryOneLine

queryOneLine :: String
queryOneLine = String.replaceAll (Pattern "\n") (Replacement " ") query

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
