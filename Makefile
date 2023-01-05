.PHONY: build doc install uninstall test clean

build:
	dune build @install

doc:
	dune build @doc

install:
	dune install

uninstall:
	dune uninstall

test:
	dune test

clean:
	dune clean
