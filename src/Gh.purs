module Gh (post) where

import Prelude
import Affjax (Error, Response, printError)
import Affjax as AX
import Affjax.RequestBody as RequestBody
import Affjax.RequestHeader (RequestHeader(..)) as RequestHeader
import Affjax.ResponseFormat as ResponseFormat
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Foreign (MultipleErrors)
import Simple.JSON (class ReadForeign, readJSON)

type ErrorReponse
  = { message :: String
    , documentation_url :: String
    }

type DataResponse a
  = { data :: a }

type ViewerResponse
  = { viewer :: { login :: String } }

decodeErrorResponse :: String -> Either MultipleErrors ErrorReponse
decodeErrorResponse = readJSON

decodeDataResponse :: forall a. ReadForeign a => String -> Either MultipleErrors (DataResponse a)
decodeDataResponse = readJSON

post :: String -> Aff (Either String String)
post token = do
  result <- AX.request $ buildRequest token
  pure $ parseResult result

parseResult :: Either Error (Response String) -> Either String String
parseResult = case _ of
  Left e -> Left $ "http error: " <> printError e
  Right res -> case decodeDataResponse res.body of
    Left e -> Left $ "json decode error: " <> show e
    Right (result :: DataResponse ViewerResponse) -> Right $ result.data.viewer.login

buildRequest :: String -> AX.Request String
buildRequest token =
  AX.defaultRequest
    { url = "https://api.github.com/graphql"
    , method = Left POST
    , headers =
      [ RequestHeader.RequestHeader "Authorization" $ "bearer " <> token
      ]
    -- []
    , content = Just $ RequestBody.string """{"query": "query { viewer { login } }"}"""
    , responseFormat = ResponseFormat.string
    }
