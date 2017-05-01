{-# LANGUAGE OverloadedStrings #-}
import Network.HTTP.Types
import Network.Wai
import Network.Wai.Handler.Warp
import System.Directory
import System.Environment
import System.FilePath
import qualified Data.ByteString.Lazy as BS
import qualified Data.Text as T

main = do
  [port, docRoot] <- getArgs
  run (read port) $ waiApp docRoot

waiApp docRoot request respond = response >>= respond
  where path = joinPath $ docRoot : map T.unpack (pathInfo request)
        response =
          if requestMethod request == "POST"
          then strictRequestBody request >>= doPost path
          else return $ responseLBS status405 [] "Method not Allowed"

doPost path content = do
  createDirectoryIfMissing True $ takeDirectory path
  BS.appendFile path content
  BS.appendFile path "\n"
  return $ responseLBS status200 [] ""
