{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}

module Data.Discord.SendOperation where

import Control.Lens.TH
import Data.Aeson (FromJSON, ToJSON)
import RIO

data SendOperation
  = Identify
  | Resume
  | Heartbeat
  | RequestGuildMembers
  | UpdateVoiceState
  | UpdatePresence
  deriving (Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

-- | Get operationCode
-- >>> operationCode Identify
-- 2
-- >>> operationCode Resume
-- 6
-- >>> operationCode Heartbeat
-- 1
-- >>> operationCode RequestGuildMembers
-- 8
-- >>> operationCode UpdateVoiceState
-- 4
-- >>> operationCode UpdatePresence
-- 3
operationCode :: SendOperation -> Int
operationCode code = case code of
  Identify -> 2
  Resume -> 6
  Heartbeat -> 1
  RequestGuildMembers -> 8
  UpdateVoiceState -> 4
  UpdatePresence -> 3

makeLenses ''SendOperation
