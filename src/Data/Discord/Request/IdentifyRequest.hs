{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}

module Data.Discord.Request.IdentifyRequest where

import Data.Aeson (ToJSON)
import Data.Bits
import Data.Text qualified as DT
import RIO

messageContentIntent :: Integer
messageContentIntent = shift 1 15

guildMessageContentIntent :: Integer
guildMessageContentIntent = shift 1 9

guildManageChannelsIntent :: Integer
guildManageChannelsIntent = shift 1 4

guildManageServerIntent :: Integer
guildManageServerIntent = shift 1 5

data IdentifyRequestProperties = IdentifyRequestProperties
  { os :: String,
    browser :: String,
    device :: String
  }
  deriving (Show, Generic, Eq)
  deriving anyclass (ToJSON)

data IdentifyRequest = IdentifyRequest
  { token :: DT.Text,
    intents :: Integer,
    properties :: IdentifyRequestProperties
  }
  deriving (Show, Generic, Eq)
  deriving anyclass (ToJSON)

defaultIdentifyRequestProperties :: IdentifyRequestProperties
defaultIdentifyRequestProperties =
  IdentifyRequestProperties
    { os = "Linux",
      browser = "browser",
      device = "server"
    }

defaultIntents :: Integer
defaultIntents = messageContentIntent .|. guildMessageContentIntent .|. guildManageChannelsIntent .|. guildManageServerIntent

defaultIdentifyRequest :: DT.Text -> IdentifyRequest
defaultIdentifyRequest token =
  IdentifyRequest
    { token = token,
      intents = defaultIntents,
      properties = defaultIdentifyRequestProperties
    }
