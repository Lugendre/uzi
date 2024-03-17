{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}

module Effectful.DiscordChannel.Interpreter where

import Control.Lens
import Data.Aeson
import Data.Coerce (coerce)
import Data.Discord.ChannelId
import Data.Text (Text)
import Data.Text.Encoding
import Effectful
import Effectful.DiscordApiTokenReader (DiscordApiTokenReader, getToken)
import Effectful.DiscordChannel.Effect
import Effectful.Dispatch.Dynamic (interpret)
import Effectful.Req (Request, request)
import Network.HTTP.Req (POST (POST), ReqBodyJson (ReqBodyJson), header, https, ignoreResponse, (/:))

host :: Text
host = "discord.com"

runDiscordChannel :: (DiscordApiTokenReader :> es, Request :> es) => Eff (DiscordChannel : es) a -> Eff es a
runDiscordChannel = interpret $ \_ -> \case
  SendMessage params -> do
    token <- getToken
    _ <-
      request POST (https host /: "api" /: "v10" /: "channels" /: coerce (params ^. channelId) /: "messages") (ReqBodyJson . toJSON $ params) ignoreResponse $
        header "Authorization" ("Bot " <> encodeUtf8 token)
    pure ()
