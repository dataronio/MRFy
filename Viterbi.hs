{-# LANGUAGE BangPatterns #-}
module Viterbi where

import Debug.Trace (trace)
-- import Debug.Trace.LocationTH (check) 
import qualified Data.MemoCombinators as Memo
import qualified Data.List as DL

import Beta
import HmmPlus
import Data.Vector hiding (minimum, (++), map)
import Constants

type QuerySequence = Vector Int -- indices into Constants.amino
type Score = Double
type StatePath = [ HMMState ]

-- Remember, for states, 0 is a match, 1 is insertion and 2 is deletion.
-- It must be this way because the Pads parser does not support non-base
-- types as the parameter for an algebraic parser type. *sigh*
-- mat = 0 :: HMMState 
-- ins = 1 :: HMMState 
-- del = 2 :: HMMState 
-- beg = 3 :: HMMState 
-- end = 4 :: HMMState 
-- bmat = 5 :: HMMState 

type ScorePathCons a = a -> [a] -> [a]
type Result = (Score, StatePath)

unscore :: Scored a -> (Score, a)
unscore (Scored a x) = (x, a)

consPath :: ScorePathCons a
consPath x xs = x:xs

consNoPath :: ScorePathCons a
consNoPath _ _ = []

type TProb = TransitionProbability
type TProbs = TransitionProbabilities

-- hasStart and hasEnd are (for now) for model-relative local alignment.
-- when we want to consider sequence-relative local alignment, we
-- will also need to consider better of seqLocal vs. modLocal
viterbi :: ScorePathCons HMMState -> (Bool, Bool) -> Alphabet -> QuerySequence -> HMM -> Result
viterbi pathCons (hasStart, hasEnd) alpha query hmm =
  if numNodes == 0 then
    (0.0, [])
  else
    flipSnd $ DL.minimum $ DL.map unscore $
    [vee' Mat (numNodes - 1) (seqlen - 1),
     vee' Ins (numNodes - 1) (seqlen - 1),
     vee' Del (numNodes - 1) (seqlen - 1)
    ] DL.++ if hasEnd then [bestEnd] else []


  -- trace (show state DL.++ " " DL.++ show node DL.++ " " DL.++ show obs) $
  where 
        -- @ start memo.tex -8
        vee' state j i =
          Memo.memo3 (Memo.arrayRange (Mat, End)) 
                     (Memo.arrayRange (0, numNodes))
                     (Memo.arrayRange (0, seqlen)) 
                     vee'' state j i
        -- @ end memo.tex

        bestEnd = vee' End (numNodes - 1) (seqlen - 1)

        -- we see observation obs with node at state
        flipSnd pair = (fst pair, DL.reverse $ snd pair)

        numNodes = Data.Vector.length $ hmm
        seqlen = Data.Vector.length query

        res i = query ! i

        eProb j i = emissionProb (matchEmissions $ hmm ! j) (res i)
        tProb f j = transProb hmm j f
        -- @ start edge.tex -8
        edge :: HMMState -> HMMState -> (TProbs -> TProb)
        -- @ end edge.tex
        edge Mat Mat = m_m
        edge Mat Ins = m_i
        edge Mat Del = m_d
        edge Ins Mat = i_m
        edge Ins Ins = i_i
        edge Del Mat = d_m
        edge Del Del = d_d
        edge Beg Mat = b_m
        edge Mat End = m_e
        edge f   t   = error $ "HMM edge " ++ show f ++ " -> " ++ show t ++
                               "is allowed in the Plan7 architecture"

        insertProb j i = emissionProb (insertionEmissions $ hmm ! j) (res i)
        matchProb  j i = emissionProb (matchEmissions     $ hmm ! j) (res i)

        disallowed = Scored [] maxProb

        -- node 1 and zeroth observation
        vee'' Mat 1 0 = Scored [Mat] (tProb m_m 0 + matchProb 1 0)
                            --           ^^^^^^^^^^^^^ is this right?  ---NR
                            -- we came from 'begin'
        vee'' Ins 1 0 = disallowed
        vee'' Del 1 0 = disallowed

        -- node 0 and zeroth observation, base of self-insert
        vee'' Mat 0 0 = disallowed
        vee'' Ins 0 0 = Scored [Ins] (tProb m_i 0 + insertProb 0 0)
        vee'' Del 0 0 = disallowed

        -- node 0 and no observations
        vee'' Mat 0 (-1) = Scored [] (tProb m_m 0)
        vee'' Ins 0 (-1) = disallowed
        vee'' Del 0 (-1) = disallowed

        -- node 0 but not zeroth observation
        vee'' Mat 0 i = disallowed
        vee'' Ins 0 i = fmap (pathCons Ins) $
                            (tProb i_i 0 + insertProb 0 i) /+/ vee' Ins 0 (i-1)
                            -- possible self-insert cycle

        vee'' Del 0 i = disallowed
        vee'' End 0 i = Scored [Mat] (tProb m_e 0)

        -- node 1 and no more observations (came from begin)
        vee'' Mat 1 (-1) = disallowed
        vee'' Ins 1 (-1) = disallowed
        vee'' Del 1 (-1) = Scored [Del] (tProb m_d 0) -- came from begin

        -- not node 1 yet, but not more observations (came from delete)
        vee'' Mat j (-1) = disallowed
        vee'' Ins j (-1) = disallowed
        vee'' Del j (-1) = fmap (pathCons Del) $
                               tProb d_d (j - 1) /+/ vee' Del (j - 1) (-1)

        -- consume an observation AND a node
        -- I think only this equation will change when
        -- we incorporate the begin-to-match code
        --------------------------------------------------------
        -- @ start viterbi.tex -8
        vee'' Mat j i = fmap (pathCons Mat)
          (eProb j i /+/ myminimum (map from [Mat, Ins, Del]))
         where from prev = tProb (edge prev Mat) (j-1) /+/
                                       vee' prev (j-1) (i-1)
        -- @ end viterbi.tex
        

        -- match came from start                                            
        -- consume an observation but not a node
        vee'' Ins j i = fmap (pathCons Ins) $ eProb j i /+/
                              myminimum (DL.map from [Mat, Ins])
          where from prev = tProb (edge prev Ins) j /+/ vee' prev j (i - 1)

        -- consume a node but not an observation
        vee'' Del j i = fmap (pathCons Del) $
                              myminimum (DL.map from [Mat, Del])
          where from prev = tProb (edge prev Del) (j - 1) /+/
                              vee' prev (j - 1) i

        vee'' End j i = fmap (pathCons End) $ myminimum $
                              if j >= 2 then
                                (DL.map from [Mat, End])
                              else
                                [from Mat]
          where from prev = case prev of
                              Mat -> tProb (edge prev Mat) (j - 1) /+/
                                       vee' prev (j - 1) i
                              otherwise -> vee' prev (j - 1) i
                        -- for local to QUERY we would do j, i-1.

-- TODO seqLocal: consider the case where we consume obs, not state, for beg & end.

-- TODO preprocessing: convert hmm to array of nodes with the stateZero and insertZero stuff prepended
-- this will transform `node` below and `transProb` below

emissionProb :: Vector a -> Int -> a
emissionProb emissions residue = emissions ! residue

-- possible speedup: avoid this case analysis; substitute for maxProb in HmmPlus
transProb :: HMM -> Int -> StateAcc -> Double
transProb hmm nodenum state = case logProbability $ state (transitions (hmm ! nodenum)) of
                                   NonZero p -> p
                                   LogZero -> maxProb

myminimum :: Ord a => [Scored a] -> Scored a
myminimum [] = error "naughty"
myminimum (s:ss) = minimum' s ss
  where minimum' min [] = min
        minimum' min (s:ss) = minimum' min' ss
          where min' = if s < min then s else min

-- @ start vscore.tex
data Scored a = Scored a Score
(/+/) :: Score -> Scored a -> Scored a
-- @ end vscore.tex

instance Eq a => Eq (Scored a) where
  x == x' = scoreOf x == scoreOf x' && value x == value x'
    where value (Scored a _) = a
instance Eq a => Ord (Scored a) where
  x < x' = scoreOf x < scoreOf x'

instance Functor Scored where
  fmap f (Scored a x) = Scored (f a) x

instance Show (Scored a) where
  show (Scored a x) = show x

scoreOf :: Scored a -> Score
scoreOf (Scored _ x) = x

infix /+/
x /+/ Scored a y = Scored a (x + y)

