module Gh (request) where

import Prelude
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Console as Console
import Effect.Exception (Error)

type Opt
  = { callback :: Callback
    , rightf :: RightF
    , leftf :: LeftF
    , body :: Body
    , token :: Token
    }

type Callback
  = Either Error Response -> Effect Unit

type Response
  = { statusCode :: Int, body :: String }

type RightF
  = Int -> String -> Either Error Response

type LeftF
  = Error -> Either Error Response

type Body
  = String

type Token
  = String

foreign import requestImpl :: Opt -> Effect Unit

request :: String -> Effect Unit
request token = requestImpl $ opt token """{"query": "query { viewer { login } }"}"""

opt :: Token -> Body -> Opt
opt token body =
  { callback: callback
  , rightf: rightf
  , leftf: leftf
  , body: body
  , token: token
  }

callback :: Callback
callback = case _ of
  Left e -> Console.logShow e
  Right res -> Console.logShow res.body

rightf :: RightF
rightf code body = Right { statusCode: code, body: body }

leftf :: LeftF
leftf = Left
