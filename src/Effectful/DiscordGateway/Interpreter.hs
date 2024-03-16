{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}

module Effectful.DiscordGateway.Interpreter where

import Data.Aeson (eitherDecode, encode)
import Data.ByteString.Lazy (LazyByteString)
import Data.ByteString.Lazy qualified as BL
import Data.Discord
import Data.String.Conversions (ConvertibleStrings (convertString))
import Data.Text.Encoding qualified as LT
import Effectful
import Effectful.DiscordGateway.Effect
import Effectful.Dispatch.Dynamic (interpret)
import Effectful.DynamicLogger
import Effectful.Environment
import Network.Socket
import Network.WebSockets (Connection)
import Network.WebSockets qualified as WS
import Network.WebSockets qualified as Wuss
import Wuss qualified as WS

runClient :: (MonadUnliftIO m) => String -> PortNumber -> String -> WS.ConnectionOptions -> WS.Headers -> (WS.Connection -> m a) -> m a
runClient host port path opt headers inner =
  withRunInIO $ \runInIO ->
    WS.runSecureClientWith host port path opt headers (runInIO . inner)

withPingThread :: (MonadUnliftIO m) => Connection -> Int -> IO () -> m a -> m a
withPingThread conn interval after_sending inner =
  withRunInIO $ \runInIO ->
    WS.withPingThread conn interval after_sending (runInIO inner)

handleEvent :: LazyByteString -> Either String Response
handleEvent = eitherDecode @Response

withDiscordGatewayConnection :: (MonadUnliftIO m) => (WS.Connection -> m a) -> m a
withDiscordGatewayConnection = runClient "gateway.discord.gg" 443 "/?v=14&encoding-json" WS.defaultConnectionOptions []

runDiscordGateway :: (IOE :> es, Environment :> es, DynamicLogger :> es) => WS.Connection -> Eff (DiscordGateway : es) a -> Eff es a
runDiscordGateway conn = interpret $ \_ -> \case
  ReceiveEvent -> do
    d <- liftIO . Wuss.receiveData $ conn
    lookupEnv "UZI_IS_DEBUG" >>= \case
      Just _ -> info d
      Nothing -> pure ()
    case handleEvent (BL.fromStrict . LT.encodeUtf8 $ d) of
      Left s -> do
        attention . convertString $ s
        pure Nothing
      Right p -> do
        pure . Just $ p
  SendEvent request -> do
    let text = encode request
    lookupEnv "UZI_IS_DEBUG" >>= \case
      Just _ -> info . convertString $ text
      Nothing -> pure ()
    liftIO . Wuss.sendTextData conn $ text
