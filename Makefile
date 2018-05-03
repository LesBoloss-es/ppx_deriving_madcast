build:
	jbuilder build @install

doc:
	jbuilder build @doc

install:
	jbuilder install

uninstall:
	jbuilder uninstall

release:
	git tag -a v$(shell opam query *.opam --version) -m 'Version $(shell opam query *.opam --version)'
	git push origin v$(shell opam query *.opam --version)
	opam publish prepare $(shell opam query *.opam --name-version) $(shell opam query *.opam --archive)
	opam publish submit $(shell opam query *.opam --name-version)

test:
	jbuilder build test/test_ppx_deriving_madcast.exe
	_build/default/test/test_ppx_deriving_madcast.exe

clean:
	jbuilder clean
	rm -f ppx_deriving_madcast.[0-9]*

.PHONY: build doc install uninstall release test clean
