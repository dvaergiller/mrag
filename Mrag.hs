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
    [port, docRoot] | all isDigit port -> run (read port) $ waiApp lock docRoot
    _ -> putStrLn "Usage: mrag <PORT> <DOCROOT>"

waiApp lock docRoot request respond =
  case requestMethod request of
  "POST" -> respond =<< doWrite lock path =<< strictRequestBody request
  "GET"  -> respond $ responseFile status200 [] path Nothing
  _      -> respond $ responseLBS status405 [] "Method not Allowed"
  where path = joinPath $ docRoot : map T.unpack (pathInfo request)

doWrite lock path content =
  L.with lock appendLine >> return (responseLBS status200 [] "")
  where appendLine = do
          createDirectoryIfMissing True $ takeDirectory path
          BS.appendFile path $ BS.append content "\n"
