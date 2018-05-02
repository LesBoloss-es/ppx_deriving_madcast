build:
	jbuilder build @install

install:
	jbuilder install

uninstall:
	jbuilder uninstall

VERSION      := $(shell opam query ppx_deriving_madcast.opam --version)
NAME_VERSION := $(shell opam query ppx_deriving_madcast.opam --name-version)
ARCHIVE      := $(shell opam query ppx_deriving_madcast.opam --archive)

release:
	git tag -a v$(VERSION)
	git push origin v$(VERSION)
	opam publish prepare $(NAME_VERSION) $(ARCHIVE)
	opam publish submit $(NAME_VERSION)

test:
	jbuilder build test/test_ppx_deriving_madcast.exe
	_build/default/test/test_ppx_deriving_madcast.exe

clean:
	jbuilder clean
	rm -f ppx_deriving_madcast.[0-9]*

.PHONY: build install test clean
