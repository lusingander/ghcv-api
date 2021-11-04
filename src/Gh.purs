module Gh
  ( post
  , GhResponse(..)
  , ErrorResponse
  , DataResponse
  , Query
  , Token
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
import Effect.Aff (Aff)
import Simple.JSON (class ReadForeign, readJSON)
import Simple.JSON as JSON

type Query
  = String

type Token
  = String

data GhResponse a
  = Ok (DataResponse a)
  | Error ErrorResponse

instance readGhResponse :: ReadForeign a => ReadForeign (GhResponse a) where
  readImpl f = Ok <$> JSON.readImpl f <|> Error <$> JSON.readImpl f

type ErrorResponse
  = { message :: String
    , documentation_url :: String
    }

type DataResponse a
  = { data :: a }

post :: forall a. ReadForeign a => Query -> Token -> Aff (Either String (GhResponse a))
post query token = do
  result <- AX.request $ buildRequest query token
  pure $ parseResult result

parseResult :: forall a. ReadForeign a => Either Error (Response String) -> Either String (GhResponse a)
parseResult = case _ of
  Left e -> Left $ "http error: " <> printError e
  Right res -> case readJSON res.body of
    Left e -> Left $ "json decode error: " <> show e
    Right (result :: (GhResponse a)) -> Right $ result

buildRequest :: Query -> Token -> AX.Request String
buildRequest query token =
  AX.defaultRequest
    { url = "https://api.github.com/graphql"
    , method = Left POST
    , headers =
      [ RequestHeader.RequestHeader "Authorization" $ "bearer " <> token
      ]
    , content = Just $ RequestBody.string $ buildQueryJson query
    , responseFormat = ResponseFormat.string
    }

buildQueryJson :: Query -> String
buildQueryJson query = """ {"query": " """ <> query <> """ "} """
