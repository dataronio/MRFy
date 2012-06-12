{-# LANGUAGE ScopedTypeVariables, BangPatterns, MultiParamTypeClasses, RankNTypes, NamedFieldPuns, ExistentialQuantification #-}
{-# OPTIONS_GHC -Wall -fno-warn-name-shadowing #-}
module LazySearchModel
       ( Age
       , Aged(..), unAged, ageOf
       , History(..), unHistory, hcons, emptyHistory, historySolution
                    , extendUsefulHistory
       , scoreUtility
       , Utility(..), isUseless
       , SearchGen(..), SearchStop, SearchStrategy(..), searchStrategy
       , FullSearchStrategy(..), fullSearchStrategy, fullSearch
       , Move(..)
       , search
       , AUS
       )

where
  
import Control.Monad.Random
import Control.Monad
import Data.Function

import Score
--------------------------------------------------------

{-

Preamble
--------
Starting from a good initial state, we generate a sequence of
successor states using random numbers.  A new state may be "useful" or
"useless".  A useful state becomes the starting point for a new
search; a useless state is eventually discarded.

Both useful and useless states have *ages*; the age of a state is the
number of states (both useful and useless) that have preceded it in
the search.

Every state is assigned a *score*; the utility of a state is solely a
function of its age and score.

-}

-------------- Type definitions for central concepts ----------
-- @ start strategy.tex
type Age  = Int -- number of generations explored
-- @ end strategy.tex

-- @ start utility.tex
data Utility a = Useful a | Useless
-- @ end utility.tex

-- | A @Move@ is used to make a decision about
-- whether a younger state is useless.  The decision
-- uses the score of the most recent useful state
-- (aka the @older@ state) as well as the score and
-- age of the state under scrutiny (the @younger@ state).
-- @ start move.tex
data Move pt = Move { older      :: Scored pt
                    , younger    :: Scored pt
                    , youngerAge :: Age }
-- @ end move.tex

-- | Many internal decisions are made based on age,
-- so we provide a way to tag any value with its age.
-- @ start aged.tex
data Aged a = Aged a Age
-- @ end aged.tex
  deriving (Show, Eq, Ord)
unAged :: Aged a -> a
unAged (Aged a _) = a
ageOf :: Aged a -> Age
ageOf (Aged _ age) = age



--------------- Search strategy ---------------------------
--
-- In general, a search strategy contains not just a single
-- placement but a population of placements.   As advocated 
-- by Hughes, a strategy is divided into two parts: generate
-- and (stop) test.
-- @ start strat.tex
data SearchStrategy pt r =
  SS { searchGen  :: SearchGen pt r
     , searchStop :: SearchStop pt }
-- @ end strat.tex

-- Why doesn't the generator take a random thing and produce an
-- infinite list of scored populations?  Because that would imply that
-- *every* population is useful.
--
--

-- @ start gen.tex
data SearchGen pt r = 
 SG { pt0     :: Rand r (Scored pt)
    , nextPt  :: Scored pt -> Rand r (Scored pt)
    , utility :: Move pt -> Rand r (Utility (Scored pt))
    }
-- @ end gen.tex
 -- ^ utility returns the *younger* item in the delta

 -- | In a just world, a search would produce an infinite list of
 -- useful states tagged with score and age, and the stop function
 -- would grab a prefix.  Unfortunately, to guarantee productivity, we
 -- must include useless states.
 --
 -- A simple stop function would take this list and produce a result
 -- (value of type @a@) or perhaps a @Scored a@.  But because we are
 -- doing research into the convergence properties of various search
 -- strategies, we want to retain information about *all* useful
 -- states.  That is the role of @History@.  The list is always
 -- finite, and the youngest solution is at the beginning.
 --
 -- XXX this whole 'Age' thing is bogus.  Younger values have *larger* Ages!
 -- We need a short word meaning 'birthday' or 'date of manufacture'.
 
-- @ start history.tex
data History placement = History [Aged (Scored placement)]
-- @ end history.tex
  deriving (Show, Eq)
unHistory :: History a -> [Aged (Scored a)]
unHistory (History a) = a

-- | A stop function converts an infinite sequence of states into a
-- history.  It requires as a precondition that the input be infinite
-- and that the first state be useful.
-- @ start stop.tex
type SearchStop a = [Aged (Utility (Scored a))] -> History a
-- @ end stop.tex


-- | A constructor for search strategies.  Its role is to take
-- four flat arguments instead of a tree.  (Not sure this is a 
-- good idea.)
searchStrategy :: (Rand gen (Scored placement))
               -> (Scored placement -> Rand gen (Scored placement))
               -> (forall a . Move a -> Rand gen (Utility (Scored a)))
               -> SearchStop placement
               -> SearchStrategy placement gen
searchStrategy g0 n u s = SS (SG g0 n u) s



-------------- History ------------------------
--
-- If we 

instance Functor History where
  fmap f = History . (fmap . fmap . fmap) f . unHistory

-- data History placement = History [Aged (Scored placement)]



hcons :: Aged (Scored placement) -> History placement -> History placement
hcons a (History as) = History (a:as)
emptyHistory :: History a
emptyHistory = History []
historySolution :: History a -> Scored a
historySolution (History (asp : _)) = unAged asp
historySolution _ = error "solution from empty history"

extendUsefulHistory :: AUS a -> History a -> History a
extendUsefulHistory (Aged Useless _) h = h
extendUsefulHistory (Aged (Useful a) age) h = Aged a age `hcons` h




type AUS a = Aged (Utility (Scored a))


instance Functor Aged where
  fmap f (Aged a age) = Aged (f a) age


scoreUtility :: Move a -> Rand gen (Utility (Scored a))
scoreUtility (Move { younger, older }) = return $
  if scoreOf younger < scoreOf older then Useful younger else Useless
                                         
instance Functor Utility where 
  fmap f (Useful a) = Useful (f a)
  fmap _ Useless    = Useless

isUseless :: Utility a -> Bool
isUseless Useless    = True
isUseless (Useful _) = False

instance Ord (History a) where
  compare = compare `on` map unAged . unHistory
    -- ^ Histories are compared by the score of the youngest element.

-------------------------------------------------------V
-- @ start everygen.tex
everyPt :: SearchGen pt r -> Age -> Scored pt
         -> Rand r [Aged (Utility (Scored pt))]
everyPt ss age startPt = do
  successors <- mapM (nextPt ss) (repeat startPt)
  tagged <- zipWithM agedUtility successors [succ age..]
  let (useless, Aged (Useful newPt) newAge : _) =
                        span (isUseless . unAged) tagged
  nextPts <- everyPt ss newAge newPt
  return $ Aged (Useful startPt) age : useless ++ nextPts

  where agedUtility pt age =
           utility ss move >>= \u -> return $ Aged u age
         where move = Move { older = startPt, younger = pt
                           , youngerAge = age }
-- @ end everygen.tex

  
--------------------------------------------------------
-- @ start search.tex
search :: SearchStrategy pt r -> Rand r (History pt)
search (SS strat test) =
  fmap test . everyPt strat 0 =<< pt0 strat
-- @ end search.tex

data FullSearchStrategy placement gen =
  forall a . FSS { fssGen :: SearchGen a gen
                 , fssStop :: SearchStop a
                 , fssBest :: a -> placement }

-- @ start fullsearch.tex
fullSearch :: FullSearchStrategy a r -> Rand r (History a)
fullSearch (FSS gen stop best) = fmap (fmap best . stop) . everyPt gen 0 =<< pt0 gen
-- @ end fullsearch.tex        


fullSearchStrategy :: (Rand gen (Scored placement))
                   -> (Scored placement -> Rand gen (Scored placement))
                   -> (forall a . Move a -> Rand gen (Utility (Scored a)))
                   -> SearchStop placement
                   -> (placement -> answer)
                   -> FullSearchStrategy answer gen
fullSearchStrategy g0 n u s b = FSS (SG g0 n u) s b



-- TODO keep a Scored (Age, Placement) to support Simulated Annealing
-- otherwise, need an out of band "best ever" updated at every step
-- this is also necessary to prevent SimAn from thinking it's improving
-- when in fact it isn't.
