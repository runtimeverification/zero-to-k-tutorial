%-kompiled/interpreter: %.k
	rm -rf *-kompiled
	kompile $*.k

%-kompiled/definition.kore: %.k
	rm -rf *-kompiled
	kompile $*.k --backend haskell

calc.k: 01_calc.k.sol
	cp $< $@

calc-bool.k: 02_calc-bool.k.sol
	cp $< $@

subst.k: 03_subst.k.sol
	cp $< $@

assignment.k: 04_assignment.k.sol
	cp $< $@

#assignment.k: 04_assignment_strict.k.sol
#	cp $< $@
#
#assignment.k: 04_assignment_strict_explained.k.sol
#	cp $< $@

control-flow.k: 05_control-flow.k.sol
	cp $< $@

procedures.k: 06_procedures.k.sol
	cp $< $@

tests/%.krun:
	@echo "Input"
	@echo "====="
	cat tests/$*
	@echo ""
	@echo "Output"
	@echo "======"
	krun tests/$*

tests/%.kprove:
	@echo "Input"
	@echo "====="
	cat tests/$*
	@echo ""
	@echo "Output"
	@echo "======"
	kprove tests/$* --def-module VERIFICATION
