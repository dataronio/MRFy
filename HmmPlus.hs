{-# LANGUAGE TypeSynonymInstances, TemplateHaskell, QuasiQuotes, 
             MultiParamTypeClasses, FlexibleInstances, UndecidableInstances,
             DeriveDataTypeable, ScopedTypeVariables, NamedFieldPuns #-}
module HmmPlus 
  ( SmurfHeader
  
  , Exposure
  , StrandPair
  , firstStart
  , secondStart
  , pairLength
  , maxGap
  , parallel
  , exposure
  
  , paraOrAnti
  , getBetaPairs
  , parse
  )
where

import Language.Pads.Padsc hiding (position, head)
import Language.Pads.GenPretty
import Control.Monad
import System.IO.Unsafe (unsafePerformIO)

ws = REd "[\t ]+|$" " "

amino = "ACDEFGHIKLMNPQRSTVWY"
nucleotide = "ACTG"

[pads|
  data SmurfFile = SmurfFile { header::SmurfHeader, hmm::HMM <| (getAlphabet header, getNumNodes header) |> }
  
  type SmurfHeader = [Line HeaderLine] terminator Try (LitRE 'HMM ')
  
  data HeaderLine = HeaderLine { tag::Tag, ws, payload::Payload tag }
  
  data Tag = FileVersion "HMMER3/a" -- this string literal will change with major file version changes
            | NAME | ACC | DESC | LENG | ALPH | RF | CS | MAP | DATE | MEAN | RMSD
            | COM | NSEQ | EFFN | CKSUM | GA | TC | NC | STATS | BETA | Other (StringSE ws)
  
  data Payload (t::Tag) = case t of
      FileVersion -> Version VersionString
    | NAME -> Name StringLn
    | ACC -> Accession StringLn
    | DESC -> Description StringLn
    | LENG -> ModelLength Int
    | ALPH -> Alphabet StringLn
    | RF -> ReferenceAnnotation StringLn
    | CS -> ConsensusStructure StringLn
    | MAP -> MapAnnotation StringLn
    | DATE -> Date StringLn
    | COM -> CommandLog StringLn
    | NSEQ -> SequenceNumber Int
    | EFFN -> EffectiveSeq Double
    | CKSUM -> Checksum Int
    | GA -> PfamGathering (Double, ws, Double)
    | TC -> PfamTrusted (Double, ws, Double)
    | NC -> PfamNoise (Double, ws, Double)
    | STATS -> Stats {"LOCAL", ws, scoredist::ScoreDistribution, ws, values::[Double | ws] terminator Try EOR }
    | BETA -> Beta StrandPair
    | Other tag -> BadTag StringLn
    | otherwise -> OtherTag StringLn
    
  type VersionString = StringLn
  
  data ScoreDistribution = VLAMBDA | VMU | FTAU | MSV | VITERBI | FORWARD
  
   -- firstRes secondRes Length maxGap parallelism exposure
  data StrandPair = StrandPair {
        firstStart :: Int, ' ',
        secondStart :: Int, ' ',
        pairLength :: Int, ' ',
        maxGap :: Int, ' ',
        parallel :: Direction, ' ',
        exposure :: ExposureList
  }
    
  type ExposureList = [ Exposure ] terminator Try EOR
  data Exposure = In 'i'
                | Out 'o'  
                
  data Direction = Parallel "1"
                 | Antiparallel "-1"
  
  data HMM (alphabet :: String, numNodes :: Int) = 
       HMM { "HMM"
           , ws
           , hmmAlphabet :: [Letter alphabet | ws] length <| length alphabet |>
           , ws
           , EOR
           , ws
           , transitionHeader :: TransitionDescription
           , EOR
           , composition :: Maybe (ws, "COMPO", ws, 
                                   EmissionProbabilities alphabet, ws, EOR)
           , insertZeroEmissions :: InsertEmissions alphabet
           , stateZeroTransitions :: StateTransitions
           , nodes :: [HmmNode <| alphabet |>] terminator "//" 
             where <| numNodes == length nodes |>
           }
              
  type Letter (alphabet :: String) = constrain c :: Char 
                                     where <| c `elem` alphabet |>
  
  type EmissionProbabilities (alphabet :: String) = 
       [ Double | ws ] length <| length alphabet |> 
  
  data TransitionProbabilities = TransitionProbabilities {
      m_m :: TransitionProbability <|(0, 0)|>, ws,
      m_i :: TransitionProbability <|(0, 1)|>, ws,
      m_d :: TransitionProbability <|(0, 2)|>, ws,
      i_m :: TransitionProbability <|(1, 0)|>, ws,
      i_i :: TransitionProbability <|(1, 1)|>, ws,
      d_m :: TransitionProbability <|(2, 0)|>, ws,
      d_d :: TransitionProbability <|(2, 2)|>
  }
  
  type TransitionDescription = [ StringSE ws | ws] terminator (Try EOR)
  
  type InsertEmissions (alphabet :: String) = 
       (ws, EmissionProbabilities alphabet, ws, EOR)
  
  type StateTransitions = (ws, TransitionProbabilities, ws, EOR)
  
  data HmmNode (alphabet::String) = 
       HmmNode { ws
               , nodeNum :: Int
               , ws
               , matchEmissions :: EmissionProbabilities alphabet
               , ws
               , annotations :: EmissionAnnotationSet
               , EOR
               , insertionEmissions :: InsertEmissions alphabet
               , transitions::StateTransitions
               }
  
  type EmissionAnnotationSet = ( EmissionAnnotation
                               , ws
                               , EmissionAnnotation
                               , ws
                               , EmissionAnnotation
                               )
  
  data EmissionAnnotation = MAPA Int
                          | Unused '-'
                          | RForCS Char
                          

  data LogProbability = LogZero '*'
                      | NonZero Double
                      

  data TransitionProbability (fState::HMMState, tState::HMMState) = 
       TransitionProbability { logProbability::LogProbability
                             , fromState = value fState::HMMState
                             , toState = value tState::HMMState
                             }

  type HMMState = Int
                      
  -- do we want these to be types or newtypes? newtype enforces type checking
  -- but might prove cumbersome in the algorithm.
  -- consider just making these type aliases.        
  -- is there a way to make these newtypes but declare a mutual conversion 
  -- so we can compare them?
  -- we will want to take the max of several of these when we implement 
  -- forward algorithm
  newtype FromMatch = FromMatch LogProbability
  type MatchToMatch = FromMatch
  type MatchToInsertion = FromMatch
  type MatchToDeletion = FromMatch
  newtype FromInsertion = FromInsertion LogProbability
  type InsertionToMatch = FromInsertion
  type InsertionToInsertion = FromInsertion
  newtype FromDeletion = FromDeletion LogProbability
  type DeletionToMatch = FromDeletion
  type DeletionToDeletion = FromDeletion
|]


-- instance Eq LogProbability where
--   x == y = case (x, y) of
--             (LogZero, LogZero) -> True
--             (NonZero x', NonZero y') -> x' == y'
--             (_, _) -> False

-- instance Ord LogProbability where
--   x < y = case (x, y) of
--             (LogZero, LogZero) -> False
--             (LogZero, _) -> True
--             (NonZero _, LogZero) -> False
--             (NonZero x', NonZero y') -> x' < y'


-- MatchToMatch < MatchToInsertion
-- lt :: MatchToMatch -> MatchToInsertion -> Bool
-- lt (MatchToMatch mp) (MatchToInsertion mp') = mp < mp'

-- I think we'll want a max function on a TransitionProbabilities, which gives us the max of the 7

getAlphabet :: SmurfHeader -> String
getAlphabet ((HeaderLine {tag, payload}):xs) = case tag of
                    ALPH -> case payload of
                              Alphabet "amino" -> amino
                              Alphabet "nucleotide" -> nucleotide
                              otherwise -> error "Invalid alphabet"
                    otherwise -> getAlphabet xs

getNumNodes :: SmurfHeader -> Int
getNumNodes ((HeaderLine {tag, payload}):xs) = case tag of
                    LENG -> case payload of
                              ModelLength i -> i
                              otherwise -> error "Invalid model length"
                    otherwise -> getNumNodes xs
                    


getTag :: Tag -> SmurfHeader -> Payload
getTag t ((HeaderLine {tag, payload}):xs) = if tag == t
                                              then payload
                                            else
                                              getTag t xs
getTag t [] = error "Tag not found"  

-- This is a hack since I cannot seem to expose the type constructors for
-- Direction. (Which is declared in the Pads flib flab above.)
paraOrAnti :: Direction -> a -> a -> a
paraOrAnti p when_para when_anti = case p of Parallel -> when_para
                                             Antiparallel -> when_anti

getBetaPairs :: SmurfHeader -> [StrandPair]
getBetaPairs (HeaderLine {tag = tag, payload = payload}:xs) = 
  case tag of
       BETA -> case payload of 
                    Beta b -> b:getBetaPairs xs
                    otherwise -> error "Invalid beta"
       otherwise -> getBetaPairs xs                    
getBetaPairs [] = []                
                
-- What is "SmurfFile_md" ? o_0
parse :: FilePath -> IO (SmurfHeader, HMM, SmurfFile_md)
parse f = do (SmurfFile header hmm, md) <- parseFile f
             return (header, hmm, md)
