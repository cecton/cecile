#!/usr/bin/env runhaskell

import System.IO
import System.Environment
import Control.Exception

import Crypto.Hash.SHA1 (hash)
import Data.ByteString.Char8 (pack, unpack)
import Data.ByteString.Base64 (encode)
import Data.Char (chr, ord)

-- | main function
main :: IO ()
main = do
    cmd <- getProgName
    args <- getArgs
    case args of
        ["--help"] -> putStrLn $ "usage: " ++ cmd ++ " [<site>]"
        [site] -> do
            pwd <- finally (noecho $ ask "Password: ") (hPutStrLn stderr "")
            hPutStrLn stderr $ "Hint: " ++ hint pwd
            putStrLn $ genpass pwd site
        _ -> do
            pwd <- finally (noecho $ ask "Password: ") (hPutStrLn stderr "")
            site <- ask "Site: "
            hPutStrLn stderr $ "Hint: " ++ hint pwd
            putStrLn $ genpass pwd site

-- | genpass (from sailfish-passy)
hint pwd = take 6 $ genpass pwd "foo"

genpass :: String -> String -> String
genpass p s = (take 26) . passwordify . unpack . encode . hash . pack $
              '_' : p ++ '_' : s ++ ['_']

passwordify :: String -> String
passwordify (a:b:c:d:l) = chr ((ord 'A') + (ord a) `mod` 26) :
                          chr ((ord 'a') + (ord b) `mod` 26) :
                          chr ((ord '0') + (ord c) `mod` 10) :
                          symbols !! ((ord d) `mod` (length symbols)) :
                          l

symbols = "!?+-=*/@#$%&()[];:,.<>"

-- | helpers
ask :: String -> IO String
ask prompt = do
    hPutStr stderr prompt
    hFlush stderr
    getLine

noecho :: IO a -> IO a
noecho action = do
    old <- hGetEcho stdin
    bracket_ (hSetEcho stdin False) (hSetEcho stdin old) action
