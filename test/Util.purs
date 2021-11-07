module Test.Util (test) where

import Prelude
import Data.Either (isLeft, isRight)
import Effect (Effect)
import Test.Assert (assert, assertEqual)
import Util (formatQuery, validGhUserId)

test :: Effect Unit
test = do
  testFormatQuery
  testValidGhUserId

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
