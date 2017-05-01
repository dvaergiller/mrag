{-# LANGUAGE OverloadedStrings #-}
import Network.HTTP.Types
import Network.Wai
import Network.Wai.Handler.Warp
import qualified Data.ByteString.Lazy as BS
import qualified Data.Text as T

main = run 8083 waiApp
  where waiApp request respond = do
          content <- strictRequestBody request
          let path = T.unpack . T.intercalate "/" $ "docroot" : pathInfo request
          BS.appendFile path (BS.append content "\n")
          respond $ responseLBS status200 [] ""
