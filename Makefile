STRATS=`echo SearchStrategies/*.hs`
SRC=$STRATS Beta.hs Constants.hs HmmPlus.hs Main.hs Viterbi.hs \
         StochasticSearch.hs SearchStrategy.hs \
         Wrappers.hs ConstantsGen.hs CommandArgs.hs SearchModel.hs \
				 Score.hs SearchStrategies.hs

TGT=mrfy
CRUDOPTS= -hidir .crud -odir .crud
OPTS= -fspec-constr-count=6

all:
	mkdir -p .crud
	ghc $(OPTS) $(CRUDOPTS) --make Main.hs \
			-O3 \
			-threaded \
			-rtsopts \
			-o $(TGT)

optimize:
	mkdir -p .crud
	ghc $(OPTS) $(CRUDOPTS) --make $(SRC) \
			-O3 \
			-fllvm \
			-o $(TGT)

unopt: unoptimize
unoptimize:
	mkdir -p .crud
	ghc $(OPTS) $(CRUDOPTS) --make $(SRC) -o $(TGT)
            
profile:
	mkdir -p .crud
	ghc $(OPTS) $(CRUDOPTS) \
			--make Main.hs -O3 -fforce-recomp \
			 -rtsopts \
			 -o $(TGT)
	ghc $(OPTS) $(CRUDOPTS) \
			--make Main.hs -O3 -prof -fforce-recomp \
			 -auto-all -caf-all -rtsopts -osuf p_o \
			 -o ${TGT}prof

tags:
	hasktags *.hs

clean:
	rm -rf .crud
	rm -f $(TGT)

test: $(TGT)
	./$(TGT) testing/8.hmm+ testing/8.fasta


# note: to build profile: ghc --make Main.hs -O3 -rtsopts -o $TGT
# then, ghc --make Main.hs -O3 -prof -auto-all -caf-all -rtsopts -osuf p_o -o $TGT