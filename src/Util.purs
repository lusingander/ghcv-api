module Util
  ( formatQuery
  ) where

import Prelude
import Data.Array (foldl)
import Data.String (Pattern(..), Replacement(..))
import Data.String (replace, replaceAll) as String

formatQuery :: String -> Array { marker :: String, value :: String } -> String
formatQuery = oneLine >>> replaceMarkers

replaceMarkers :: String -> Array { marker :: String, value :: String } -> String
replaceMarkers = foldl replaceMarker

replaceMarker :: String -> { marker :: String, value :: String } -> String
replaceMarker src { marker: marker, value: value } = String.replace (Pattern marker) (Replacement value) src

oneLine :: String -> String
oneLine = String.replaceAll (Pattern "\n") (Replacement " ")
