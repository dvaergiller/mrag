{-# LANGUAGE OverloadedStrings #-}
import Network.HTTP.Types
import Network.Wai
import Network.Wai.Handler.Warp
import System.FilePath
import qualified Data.ByteString.Lazy as BS
import qualified Data.Text as T

main = run 8083 waiApp

waiApp request respond =
  strictRequestBody request >>= doPost >>= respond
  where path = joinPath $ "docroot" : map T.unpack (pathInfo request)
        doPost content = do
          BS.appendFile path (BS.append content "\n")
          return (responseLBS status200 [] "")
