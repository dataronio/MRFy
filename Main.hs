{-# LANGUAGE DeriveDataTypeable #-}

module Main where

import System.Console.CmdArgs

import Beta
import HmmAlign
import HmmPlus

data SmurfArgs = SmurfArgs { hmmPlusFile :: FilePath }
  deriving (Show, Data, Typeable)

smurfargs = SmurfArgs { hmmPlusFile = def &= typ "HMM Plus file" &= argPos 0 }

-- to be removed
querySeq = listArray (1, 10) "ADBEHAQITP"

main = do sargs <- cmdArgs smurfargs
          (header, hmm, md) <- parse $ hmmPlusFile sargs
          putStrln $ show $ hmmAlign querySeq hmm
          putStrLn $ show $ getBetaStrands header
          

