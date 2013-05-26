module FileOps
       ( Commanded(..)
       , loadTestData, translateQuery
       , runCommand
       )
where
  
import Control.Monad.LazyRandom
import Control.Parallel.Strategies
import ParRandom

import Data.Array
import Data.List as DL
import System.Console.CmdArgs
import System.Random (getStdGen, mkStdGen, randoms)
import qualified Data.Vector.Unboxed as V hiding (map)
import System.Environment
import Test.QuickCheck

import Bio.Sequence.Fasta

import Beta

import CommandArgs
import Constants
import HMMArby
import HMMPlus
import HMMProps
import HyperTriangles
import LazySearchModel
import MRFTypes
import Perturb
import RunPsiPred
import Score
import SearchStrategy (tickProp)
import ShowAlignment
import StochasticSearch
import Viterbi

import Model2 (toHMM, slice, Slice(..), numNodes)
import V4 hiding (statePath)

import qualified ModelToC as ModC


loadTestData :: Files -> IO (HMMHeader, HMM, [QuerySequence])
loadTestData files =
  do querySeqs <- readFasta $ fastaF files
     mrf <- parseMRF $ hmmPlusF files
     return (hmmHeader $ checkMRF mrf, hmm $ checkMRF mrf, map (translateQuery . toStr . seqdata) querySeqs)
     
translateQuery :: String -> QuerySequence
translateQuery = V.fromList . map lookup
  where lookup k = case V.elemIndex k Constants.amino of
                        Just i -> AA i
                        Nothing -> error "Residue not found in alphabet"

admissible :: String -> Files -> IO ()
admissible what files =
  do test <- loadTestData files
     res <- quickCheckResult (oneTestAdmissible test)
     putStrLn $ "Function viterbiAdmissible " ++
        (case res of { Success {} -> "passes"; _ -> "DOES NOT PASS" }) ++
                      " test " ++ what

mini8, t8, micro8 :: Files
mini8  = Files "testing/mini8.hmm+" "testing/mini8.fasta" "/dev/null"
t8     = Files "testing/8.hmm+"     "testing/8.fasta"     "/dev/null"
micro8 = Files "testing/micro8.hmm+" "testing/micro8.fasta" "/dev/null"

data Test = T { testName :: String, runTest :: IO () }
namedTests :: [Test]
namedTests =
  [ T (prefix ++ name ++ suffix) (action files)
  | (name, files) <- [("mini8", mini8), ("8", t8), ("micro8", micro8)]
  , (prefix, action, suffix) <- [ ("", admissible name, "")
                                , ("", runOne, "-strings")
                                , ("all-perturb-",   runp oneAllMoversPerturb, "")
                                , ("decay-perturb-", runp oneDecayMoversPerturb, "")
                                , ("local-perturb-", runp oneLocalPerturb, "")
                                ]
  ] ++
  [ T "plan7GenProp" $ quickCheck isPlan7Prop
  , T "tickProp" $ quickCheck tickProp
  , T "ubProp" $ quickCheck ubProp
  , T "buProp" $ quickCheck buProp

  , T "blockNoMergeProp" $ quickCheck blockNoMergeProp
  , T "mergeMergeProp" $ quickCheck mergeMergeProp

  , T "countEnumLaw" $ quickCheck countEnumLaw
  , T "pointsWidthLaw" $ quickCheck pointsWidthLaw
  , T "twoCountsLaw" $ quickCheck twoCountsLaw

  , T "freqLaw" $ quickCheck freqLaw
  , T "isEnumLaw" $ quickCheck isEnumLaw
  , T "randomLaw" $ quickCheck randomLaw

  , T "consistent-scoring" $ quickCheck consistentScoring
  , T "scoreable-metrics" $ quickCheck scoreableMetrics
  , T "viterbi-awesome" $ quickCheck viterbiIsAwesome

  , T "all-perturb" $ runNamedProps perturbProps
  , T "all-props" $ runNamedProps $ perturbProps ++ hmmProps ++ hyperProps

  , T "fight" $ quickCheck viterbiFight
  , T "fight-path" $ quickCheck viterbiFightPath

  , T "tree-consistent" $ quickCheck costTreeConsistent
  ]

  where runNamedProps props = mapM_ run $ props
        run (s, p) = do { putStrLn ("Testing " ++ s); quickCheck p }
        runp perturb files = putStrLn . perturb =<< loadTestData files
        runOne files = mapM_ putStrLn . oneTestResults =<< loadTestData files



runCommand :: Commanded -> IO ()

runCommand (TestHMM "all") = sequence_ $ map runTest namedTests
runCommand (TestHMM t) =
  case find ((== t) . testName) namedTests of
    Just t -> runTest t
    Nothing -> error $ "I never heard of test " ++ t ++ "; try\n" ++
                       concatMap ((\n -> "  " ++ n ++ "\n") . testName) namedTests

runCommand (TestViterbiPath searchParams
                (files @ Files { hmmPlusF = hmmPlusFile, outputF = outFile})) = do
  (header, ohmm, queries) <- loadTestData files
  let hmm = toHMM ohmm
  let model = slice hmm (Slice { width = numNodes hmm, nodes_skipped = 0 })
  let scores = map (vTest model) queries
  mapM_ putStrLn scores
    where vTest m q = show $ scoredPath m q
  
-- use `viterbiPasses` from `searchParams` and `scorePlusX`...
runCommand (TestViterbi searchParams
                (files @ Files { hmmPlusF = hmmPlusFile, outputF = outFile})) = do
  (header, ohmm, queries) <- loadTestData files
  let hmm = toHMM ohmm
  let model = slice hmm (Slice { width = numNodes hmm, nodes_skipped = 0 })
  let scores = map (vTest model) queries
  putStrLn $ show $ sum $ concat scores
    where vTest m q = map plus [1..(viterbiPasses searchParams)]
            where plus i = scorePlusX m q (Score $ fromIntegral i)

runCommand (TestOldViterbi searchParams
                (files @ Files { hmmPlusF = hmmPlusFile, outputF = outFile})) = do
  (header, model, queries) <- loadTestData files
  let scores = map (vTest model) queries
  mapM_ putStrLn scores
    where vTest h q = show $ scoreOf $ viterbi (:) HasNoEnd q h

{-
runCommand (DumpToC
                (files @ Files { hmmPlusF = hmmPlusFile, outputF = outFile})) = do
  (header, ohmm, queries) <- loadTestData files
  let hmm = toHMM ohmm
  putStrLn "#include <float.h>"
  putStrLn "#include <stdlib.h>\n"
  putStrLn "#include \"model.h\"\n"
  putStrLn (ModC.toc hmm)
-}

runCommand (AlignmentSearch searchParams
                (files @ Files { hmmPlusF = hmmPlusFile, outputF = outFile })) = do
  (header, hmm, queries) <- loadTestData files
  rgn <- getStdGen
  -- secPred <- getSecondary $ fastaF files
  finish (betas header) hmm queries (randoms rgn)
      where finish bs hmm queries seeds =
              if outFile == "stdout" then
                  mapM_ putStrLn output
              else
                  mapM_ (writeFile outFile) $ intersperse "\n" output
              where popSize  = multiStartPopSize searchParams
                    searches = take popSize $ map trySearch seeds
                    trySearch r q = if alignable q bs then searchQ else noSearch
                      where searchQ = evalRand search (mkStdGen r)
                            search  = fullSearch (strat (score hmm q bs))
                            strat   = strategy searchParams hmm searchParams q bs
                    results = map (historySolution . popSearch searches) queries
                    output  = [ "Score: " ++ (show $ scoreOf $ head results) 
                              , ""
                              , concat $ intersperse "\n\n" $
                                zipWith (outputAlignment hmm bs) results queries
                              ]



outputAlignment :: HMM -> [BetaStrand] -> Scored Placement -> QuerySequence -> String
outputAlignment hmm betas ps querySeq = 
    if alignable querySeq betas
    then showAlignment hmm betas querySeq sp 60 Constants.amino
    else "Query sequence shorter than combined beta strands; no alignment possible"
  where sp = statePath hmm querySeq betas ps



popSearch :: [QuerySequence -> History Placement]
          -> QuerySequence
          -> History Placement
popSearch searches q = minimum $ (parMap rseq) (\s -> s q) searches

noSearch = CCosted (Scored [] negLogZero) 0 `hcons` emptyHistory


