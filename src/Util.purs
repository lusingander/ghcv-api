module Util
  ( formatQuery
  , validGhUserId
  , mapToArray
  , groupBy
  ) where

import Prelude
import Data.Array (foldl, snoc)
import Data.Either (Either(..))
import Data.Map (Map, empty, insert, lookup, toUnfoldable) as Map
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), Replacement(..))
import Data.String (replace, replaceAll) as String
import Data.Tuple (fst, snd) as Tuple

formatQuery :: String -> Array { marker :: String, value :: String } -> String
formatQuery = oneLine >>> replaceMarkers

replaceMarkers :: String -> Array { marker :: String, value :: String } -> String
replaceMarkers = foldl replaceMarker

replaceMarker :: String -> { marker :: String, value :: String } -> String
replaceMarker src { marker: marker, value: value } = String.replace (Pattern marker) (Replacement value) src

oneLine :: String -> String
oneLine = String.replaceAll (Pattern "\n") (Replacement " ")

foreign import userIdTest :: String -> Boolean

validGhUserId :: String -> Either String String
validGhUserId id =
  if userIdTest id then
    Right id
  else
    Left "invalid id format"

mapToArray :: forall k v. Map.Map k v -> Array { key :: k, value :: v }
mapToArray m = map (\t -> { key: Tuple.fst t, value: Tuple.snd t }) $ Map.toUnfoldable m

groupBy :: forall a b. Ord b => (a -> b) -> Array a -> Map.Map b (Array a)
groupBy f = foldl (\m e -> appendToArray f e m) Map.empty

appendToArray :: forall a b. Ord b => (a -> b) -> a -> Map.Map b (Array a) -> Map.Map b (Array a)
appendToArray f e m = Map.insert k es m
  where
  k = f e

  es = case (Map.lookup k m) of
    Just as -> snoc as e
    Nothing -> [ e ]
