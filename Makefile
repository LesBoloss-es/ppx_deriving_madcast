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

test: build
	jbuilder build .ppx/ppx_deriving_madcast/ppx.exe
	make -C test

clean:
	jbuilder clean
	rm -f ppx_deriving_madcast.[0-9]*
	make -C test clean

.PHONY: build doc install uninstall release test clean
