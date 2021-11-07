module Test.Main where

import Prelude
import Effect (Effect)
import Test.Util (test) as Util

main :: Effect Unit
main = Util.test
