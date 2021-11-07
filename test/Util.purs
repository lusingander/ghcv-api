module Test.Util (test) where

import Prelude
import Data.Either (isLeft, isRight)
import Data.Map (empty, insert) as Map
import Effect (Effect)
import Test.Assert (assert, assertEqual)
import Util (formatQuery, groupBy, mapToArray, validGhUserId)

test :: Effect Unit
test = do
  testFormatQuery
  testValidGhUserId
  testMapToArray
  testGroupBy

testFormatQuery :: Effect Unit
testFormatQuery = do
  let
    src = """foo { __a__ __b__ __c__ }"""

    markers = [ { marker: "__a__", value: "1" }, { marker: "__c__", value: "2" }, { marker: "__b__", value: "3" } ]

    actual = formatQuery src markers

    expected = """foo { 1 3 2 }"""
  assertEqual { actual: actual, expected: expected }

testValidGhUserId :: Effect Unit
testValidGhUserId = do
  assert $ isRight $ validGhUserId "foo"
  assert $ isRight $ validGhUserId "foo-bar"
  assert $ isLeft $ validGhUserId ""
  assert $ isLeft $ validGhUserId "a!"

testMapToArray :: Effect Unit
testMapToArray = do
  let
    m =
      Map.empty
        # Map.insert 1 "foo"
        # Map.insert 3 "baz"
        # Map.insert 2 "bar"

    actual = mapToArray m

    expected =
      [ { key: 1, value: "foo" }
      , { key: 2, value: "bar" }
      , { key: 3, value: "baz" }
      ]
  assertEqual { actual: actual, expected: expected }

testGroupBy :: Effect Unit
testGroupBy = do
  let
    as = [ { id: 1, name: "foo" }, { id: 4, name: "qux" }, { id: 2, name: "bar" }, { id: 3, name: "baz" } ]

    actual = groupBy (\a -> a.id `mod` 2) as

    expected =
      Map.empty
        # Map.insert 0 [ { id: 4, name: "qux" }, { id: 2, name: "bar" } ]
        # Map.insert 1 [ { id: 1, name: "foo" }, { id: 3, name: "baz" } ]
  assertEqual { actual: actual, expected: expected }
