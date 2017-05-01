{-# LANGUAGE OverloadedStrings #-}
import Network.HTTP.Types
import Network.Wai
import Network.Wai.Handler.Warp
import System.FilePath
import qualified Data.ByteString.Lazy as BS
import qualified Data.Text as T

main = run 8083 waiApp

waiApp request respond =
  if requestMethod request == "POST"
  then strictRequestBody request >>= doPost path >>= respond
  else respond $ responseLBS status405 [] "Method not Allowed"
  where path = joinPath $ "docroot" : map T.unpack (pathInfo request)

doPost path content = do
  BS.appendFile path (BS.append content "\n")
  return (responseLBS status200 [] "")
