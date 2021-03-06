module Gh
  ( post
  , GhResult
  , GhResponse(..)
  , RequestErrorResponse
  , GraphErrorResponse
  , GraphErrorDetailResponse
  , DataResponse
  , Query
  , Token
  , StatusCode
  ) where

import Prelude
import Affjax (Error, Response, printError)
import Affjax as AX
import Affjax.RequestBody as RequestBody
import Affjax.RequestHeader (RequestHeader(..)) as RequestHeader
import Affjax.ResponseFormat as ResponseFormat
import Control.Alt ((<|>))
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Effect.Aff (Aff)
import Simple.JSON (class ReadForeign, readJSON)
import Simple.JSON as JSON

endpointUrl :: String
endpointUrl = "https://api.github.com/graphql"

type Query
  = String

type Token
  = String

type StatusCode
  = Int

type GhResult a
  = Either String { statusCode :: StatusCode, response :: GhResponse a }

data GhResponse a
  = Ok (DataResponse a)
  | GraphError GraphErrorResponse
  | RequestError RequestErrorResponse

instance readGhResponse :: ReadForeign a => ReadForeign (GhResponse a) where
  readImpl f = Ok <$> JSON.readImpl f <|> GraphError <$> JSON.readImpl f <|> RequestError <$> JSON.readImpl f

type RequestErrorResponse
  = { message :: String
    , documentation_url :: String
    }

type GraphErrorResponse
  = { errors :: Array GraphErrorDetailResponse
    }

type GraphErrorDetailResponse
  = { type :: String
    , message :: String
    }

type DataResponse a
  = { data :: a }

post :: forall a. ReadForeign a => Query -> Token -> Aff (GhResult a)
post query token = do
  result <- AX.request $ buildRequest query token
  pure $ parseResult result

parseResult :: forall a. ReadForeign a => Either Error (Response String) -> GhResult a
parseResult = case _ of
  Left e -> Left $ "http error: " <> printError e
  Right res -> case readJSON res.body of
    Left e -> Left $ "json decode error: " <> show e
    Right result -> Right { statusCode: statusCode res, response: result }

statusCode :: forall a. Response a -> StatusCode
statusCode response = unwrap response.status

buildRequest :: Query -> Token -> AX.Request String
buildRequest query token =
  AX.defaultRequest
    { url = endpointUrl
    , method = Left POST
    , headers =
      [ authorizationHeader token
      ]
    , content = Just $ RequestBody.string $ buildQueryJson query
    , responseFormat = ResponseFormat.string
    }

authorizationHeader :: Token -> RequestHeader.RequestHeader
authorizationHeader token = RequestHeader.RequestHeader "Authorization" $ "bearer " <> token

buildQueryJson :: Query -> String
buildQueryJson query = """ {"query": " """ <> query <> """ "} """
