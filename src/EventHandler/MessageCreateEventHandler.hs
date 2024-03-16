{-# LANGUAGE ImpredicativeTypes #-}

module EventHandler.MessageCreateEventHandler
  ( dispatchMessageEventHandlers,
  )
where

import Control.Lens
import Data.Discord
import Data.Discord.Response.MessageCreateEventResponse (isBot, mentions)
import Effectful
import Effectful.DiscordChannel
import Effectful.NonDet
import EventHandler.MessageCreateEventHandler.Ping

dispatchMessageEventHandlers :: (DiscordChannel :> es, NonDet :> es) => Response -> Eff es ()
dispatchMessageEventHandlers res = case res of
  MessageCreate e ->
    if e ^. isBot
      then emptyEff
      else pingEventHandler res
  _ -> emptyEff
