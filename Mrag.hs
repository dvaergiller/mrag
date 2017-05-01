{-# LANGUAGE OverloadedStrings #-}
import Control.Monad
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

application lock docRoot request respond = response >>= respond
  where path = joinPath $ docRoot : map T.unpack (pathInfo request)
        response =
          case requestMethod request of
          "GET" -> doGet path
          "POST" -> strictRequestBody request >>= doPost lock path
          _ -> return $ responseLBS status405 [] "Method not Allowed"

doGet path = do
  exists <- doesFileExist path
  if exists
    then return $ responseFile status200 [] path Nothing
    else return $ responseLBS status404 [] "Not Found"

doPost lock path content = do
  appendLine lock path content
  return $ responseLBS status200 [] ""

appendLine lock path content =
  L.with lock $
  do
    createDirectoryIfMissing True $ takeDirectory path
    BS.appendFile path content >> BS.appendFile path "\n"

main = do
  args <- getArgs
  lock <- L.new
  case args of
    [port, _] | not $ all isDigit port -> usage
    [port, docRoot] -> run (read port) $ application lock docRoot
    _ -> usage
  where usage = putStrLn "Usage: mrag <PORT> <DOCROOT>"
