module ParRandom
       ( parRandom, parRandomRepeatable
       )
       where

import Control.Monad.LazyRandom
import Control.Parallel.Strategies

-- | Performs a bunch of stochastic computations in parallel.
-- Basically like @sequence@ only not sequential.
parRandom :: RandomGen r => [Rand r a] -> Rand r [a]
parRandom ms = do gens <- sequence (repeat getSplit) -- sequential
                  return $ withStrategy (parList rseq) $ zipWith evalRand ms gens

-- | Perform stochastic computations in parallel in a deterministic,
-- reproducible way.
parRandomRepeatable :: [Rand StdGen a] -> Rand StdGen [a]
parRandomRepeatable ms = do seeds <- getRandoms
                            return $ withStrategy (parList rseq) $
                                zipWith (\m s -> evalRand m (mkStdGen s)) ms seeds



