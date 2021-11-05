module Viewer
  ( viewer
  , ViewerResponse
  ) where

import Data.Either (Either)
import Effect.Aff (Aff)
import Gh as Gh

type ViewerResponse
  = { viewer :: { login :: String } }

viewer :: Gh.Token -> Aff (Either String (Gh.GhResponse ViewerResponse))
viewer = Gh.post buildQuery

buildQuery :: String
buildQuery = "query { viewer { login } }"
