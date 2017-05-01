{-# LANGUAGE OverloadedStrings #-}
import Data.Char
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
  args <- getArgs
  lock <- L.new
  case args of
    [port, docRoot] | all isDigit port ->
      run (read port) $ waiApp lock docRoot
    _ ->
      usage
  where usage = putStrLn "Usage: mrag <PORT> <DOCROOT>"

waiApp lock docRoot request respond = response >>= respond
  where path = joinPath $ docRoot : map T.unpack (pathInfo request)
        response =
          case requestMethod request of
          "GET" -> doGet path
          "POST" -> strictRequestBody request >>= doPost lock path
          _ -> return $ responseLBS status405 [] "Method not Allowed"

doGet path = do
  exists <- doesFileExist path
  return $ if exists
           then responseFile status200 [] path Nothing
           else responseLBS status404 [] "Not Found"

doPost lock path content =
  L.with lock appendLine >> return (responseLBS status200 [] "")
  where appendLine = do
          createDirectoryIfMissing True $ takeDirectory path
          BS.appendFile path $ BS.append content "\n"
