{-# LANGUAGE OverloadedStrings #-}
import Network.HTTP.Types
import Network.Wai
import Network.Wai.Handler.Warp
import System.Directory
import System.Environment
import System.FilePath
import qualified Control.Concurrent.Lock as L
import qualified Data.ByteString.Lazy as BS
import qualified Data.Text as T

main = do
  [port, docRoot] <- getArgs
  lock <- L.new
  run (read port) $ waiApp lock docRoot

waiApp lock docRoot request respond = response >>= respond
  where path = joinPath $ docRoot : map T.unpack (pathInfo request)
        response =
          case requestMethod request of
          "POST" -> strictRequestBody request >>= doPost lock path
          _ -> return $ responseLBS status405 [] "Method not Allowed"

doPost lock path content =
  L.with lock appendLine >> return (responseLBS status200 [] "")
  where appendLine = do
          createDirectoryIfMissing True $ takeDirectory path
          BS.appendFile path content
          BS.appendFile path "\n"
