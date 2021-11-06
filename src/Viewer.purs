module Viewer
  ( viewer
  , ViewerResponse
  ) where

import Effect.Aff (Aff)
import Gh as Gh

type ViewerResponse
  = { viewer :: { login :: String } }

viewer :: Gh.Token -> Aff (Gh.GhResult ViewerResponse)
viewer = Gh.post buildQuery

buildQuery :: String
buildQuery = "query { viewer { login } }"
