{-# LANGUAGE NamedFieldPuns #-}
{-# OPTIONS_GHC -Wall -fno-warn-name-shadowing #-}
module SearchStrategies.SimulatedAnnealing where

import Control.Monad.Random

import LazySearchModel
import Score
import SearchStrategy
import StochasticSearch

import qualified SearchStrategies.RandomHillClimb as RHC

nss :: NewSS
nss hmm searchP query betas scorer = fullSearchStrategy
  (fmap scorer $ RHC.initialize hmm searchP query betas)
  (RHC.mutate searchP query betas scorer)
  (boltzmannUtility searchP)
  (takeByAgeGap (acceptableAgeGap searchP))
  id

boltzmannUtility
  :: RandomGen r => SearchParameters -> SearchDelta a -> Rand r (Utility (Scored a))
boltzmannUtility searchP (SearchDelta { younger, older, youngerAge }) = do
  uniform <- getRandom
  return $ if boltzmann youngerAge (scoreOf younger) (scoreOf older) >= uniform
           then Useful younger
           else Useless
  where boltzmann :: Age -> Score -> Score -> Double
        boltzmann age (Score s1) (Score s2) =
          exp (negate (s1 - s2) / (constBoltzmann * temperature))
          where temperature = (constCooling ^^ age) * constInitTemp
                
        constBoltzmann = getSearchParm searchP boltzmannConstant
        constInitTemp = getSearchParm searchP initialTemperature
        constCooling = getSearchParm searchP coolingFactor
