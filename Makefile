%.k.kompile:
	@rm -rf *-kompiled
	@kompile $*.k --backend haskell --no-haskell-binary

tests/%.krun:
	@echo "Input"
	@echo "====="
	@ cat tests/$*
	@echo ""
	@echo "Output"
	@echo "======"
	@krun tests/$*

tests/%.k.kprove:
	@echo "Input"
	@echo "====="
	@cat tests/$*.k
	@echo ""
	@echo "Output"
	@echo "======"
	@kprove tests/$*.k
