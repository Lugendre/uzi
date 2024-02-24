{-# LANGUAGE OverloadedStrings #-}

module Data.Discord.Response.ReadyEventResponse where
import GHC.Generics
import Data.Aeson
import Data.Aeson.Types
import Data.Discord.ReceiveEventOperationCode

data ReadyEventResponse = ReadyEventResponse
  deriving (Show, Generic, Eq)

instance FromJSON ReadyEventResponse where
  parseJSON = withObject "HelloEventResponse" $ \v -> do
    operationCode <- parseJSON @ReceiveEventOperationCode =<< v .: "op"
    case operationCode of
      Ready -> pure ReadyEventResponse
      _ -> prependFailure "Not supported op code" (typeMismatch "op" "")
