
#####################################################################################################
STACK=stack --allow-different-user
BUILD_OPTS= ./opt/homebrew/opt/llvm@12/bin/opt
#####################################################################################################

test: clean
	$(STACK) test $(/opt/homebrew/opt/llvm@12/bin/opt)

bin:
	$(STACK) build $(/opt/homebrew/opt/llvm@12/bin/opt)

clean: 
	$(STACK) clean

distclean: clean 
	rm -rf .stack-work 

tags:
	hasktags -x -c src/

turnin:
	git commit -a -m "turnin"
	git push origin master

upstream:
	git remote add upstream https://github.com/cse130-assignments/01-haskell.git
  
update:
	git pull upstream master --allow-unrelated-histories

ghci:
	$(STACK) ghci
