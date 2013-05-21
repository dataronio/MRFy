{-# LANGUAGE BangPatterns, GeneralizedNewtypeDeriving, ScopedTypeVariables #-}
{-# OPTIONS_GHC -Wall -fno-warn-name-shadowing #-}

module V4
  ( hoViterbi
  , scoreOnly, scoredPath, inlinedTree, statePath, cost, Tree(..)
  , StateLabel(..)
  )
where

import Data.Array as A
import qualified Data.List as L
import qualified Data.MemoCombinators as Memo
import qualified Data.Vector.Unboxed as U

import qualified Constants as C
import Model3
import Score

import Debug.Trace (trace)

type StatePath = [ StateLabel ]

type QuerySequence = U.Vector C.AA

newtype ResidueIndex = RI Int deriving (Enum, Eq, Ix, Ord)

data StateLabel = Mat | Ins | Del
                deriving (Show, Ord, Eq, Enum, Ix, Bounded)
data Tree = FromBegin Score
          | StepFrom [Scored (StateLabel, Tree)]

statePath :: Tree -> Scored StatePath
statePath (FromBegin s) = Scored [] s
statePath (StepFrom []) = Scored [] negLogZero
statePath (StepFrom scores) = fmap ((:) state) $ (scoreOf s) /+/ next
  where next = statePath tree
        (state, tree) = unScored s
        s = minimum scores

cost :: Tree -> Score
cost (FromBegin s) = s
cost (StepFrom []) = negLogZero
cost (StepFrom scores) = scoreOf s + cost tree
  where (_, tree) = unScored s
        s = minimum scores


inlinedTree :: Model -> QuerySequence -> Tree
inlinedTree = hoViterbi FromBegin (\s l t -> Scored (l, t) s) StepFrom 

scoredPath :: Model -> QuerySequence -> Scored [StateLabel] 
scoredPath = hoViterbi (Scored []) (\s state path -> s /+/ fmap (state:) path) xminimum 
  where xminimum = L.foldl' min (Scored [] negLogZero)

scoreOnly, _lazyScoreOnly, strictScoreOnly :: Model -> QuerySequence -> Score
scoreOnly = strictScoreOnly 
_lazyScoreOnly  = hoViterbi id (\s _ s' -> s + s') minimum
strictScoreOnly = hoViterbi id (\(!s) _ (!s') -> s + s') xminimum
  where xminimum = L.foldl' min negLogZero



newtype NodeCount    = NC Int
  deriving (Enum, Ord, Eq, Num, Ix)
newtype ResidueCount = RC Int
  deriving (Enum, Ord, Eq, Num, Ix)


{-# INLINE hoViterbi #-}
-- | Higher-order implementation of the Viterbi algorithm, which can
-- be specialized to produce various outputs. 

transition :: Node -> StateLabel -> StateLabel -> Score
transition n from to = edge from to n
  where edge Mat Mat = m_m . m
        edge Mat Ins = m_i . m
        edge Mat Del = m_d . m
        edge Ins Mat = i_m . i
        edge Ins Ins = i_i . i
        edge Del Mat = d_m . d
        edge Del Del = d_d . d
        edge Del Ins = error "d_i impossible"
        edge Ins Del = error "i_d impossible"

emission :: Node -> StateLabel -> C.AA -> Score
emission n state residue =
    case state of
      Mat -> (m_emission $ m n) C./!/ residue 
      Ins -> (i_emission $ i n) C./!/ residue 
      Del -> 0
      -- _   -> error ("State " ++ (show state) ++ " cannot emit") 

preceders :: StateLabel -> [StateLabel]
preceders Mat = [Mat, Ins, Del]
preceders Ins = [Mat, Ins]
preceders Del = [Mat, Del]


hoViterbi :: forall a b .
             (Score -> a) -- ^ reaction to initial transition
          -> (Score -> StateLabel -> a -> b) -- ^ one possible child
          -> ([b] -> a) -- ^ make answer from all children
          -> Model -> QuerySequence -> a
hoViterbi leaf edge internal model rs = vee' Mat (NC $ count model) (RC $ U.length rs)
 where node    (NC j) = get model (NI j)
       residue (RC i) = rs U.! i

       {-# INLINE prevs #-}
       prevs :: [StateLabel]
             -> StateLabel
             -> (StateLabel -> NodeCount)
             -> (StateLabel -> ResidueCount)
             -> a
       -- NR: the following line is a redundant case, but it seems
       -- to every-so-slightly make things go faster.
       -- prevs []        _          _  _  = internal [] 
       prevs preceders stateRight fj fi =
        internal [ edge score state (vee'' state pj pi)
                 | state <- preceders
                 , let pi = fi state
                 , pj >= 0, pi >= 0
                 , let score = transition (node pj) state stateRight
                               + emission (node pj) state (residue pi)
                 ]
        where pj = fj stateRight

       predUnless :: forall a . Enum a => a -> StateLabel -> StateLabel -> a
       predUnless n don't_move s = if s == don't_move then n else pred n

       vee' :: StateLabel -> NodeCount -> ResidueCount -> a
       -- ^ @vee' sHat j i@ returns the min-cost path
       -- from state @Mat@ node 0 to state @sHat@ node @j@,
       -- producing the first @i@ residues from the vector @rs@.
       -- (For diagram see https://www.evernote.com/shard/s276/sh/39e47600-3354-4e8e-89f8-5c89884f9245/8880bd2c2a94dffb9be1432f12471ff2)
       -- @ start hov4.tex -7
       vee' Mat (NC 0) (RC 0) = error "reached unreachable state Mat/0/0"
       vee' Ins (NC 0) i = intoInsZero i
       vee' Mat (NC 1) i = intoMatOne i
       vee' Del (NC 1) i = intoDelOne i
       vee' stateRight j i = prevs (preceders stateRight) stateRight
                                   (predUnless j Ins) (predUnless i Del)
       -- @ end hov4.tex
               -- Ins does not consume a node; Del does not consume a residue
       -- handles special non-emitting transitions into Ins state 0 and Mat state 1
       -- as well as self-transition for Ins state 0
       intoInsZero (RC 0) = leaf (transition (node 0) Mat Ins)
       intoInsZero i = prevs [Ins] Ins (\_ -> 0) (\_ -> pred i)

       intoDelOne (RC 0) = leaf (transition (node 0) Mat Del)
       intoDelOne _      = internal []

       intoMatOne (RC 0) = leaf (transition (node 0) Mat Mat)
       intoMatOne i = prevs [Ins, Del] Mat (\_ -> 0) (predUnless i Del)


       vee'' = Memo.memo3 (Memo.arrayRange (minBound, maxBound))
                          (Memo.arrayRange (0, NC (count model - 1)))
                          (Memo.arrayRange (0, RC (U.length rs - 1)))
               vee'
