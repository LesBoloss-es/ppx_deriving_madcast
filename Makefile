build:
	jbuilder build @install

doc:
	jbuilder build @doc

install:
	jbuilder install

uninstall:
	jbuilder uninstall

release:
	printf 'Publishing...\n' \
	&& VERSION=$$(opam query *.opam --version) \
	&& NAME_VERSION=$$(opam query *.opam --name-version) \
	&& ARCHIVE=$(opam query *.opam --archive) \
	&& git tag -a "v$${VERSION}" -m "Version $${VERSION}" \
	&& git push origin "v$${VERSION}" \
	&& opam publish prepare "$${NAME_VERSION}" "$${ARCHIVE}" \
	&& opam publish submit "$${NAME_VERSION}"

test: build
	jbuilder build .ppx/ppx_deriving_madcast/ppx.exe
	make -C test

clean:
	jbuilder clean
	rm -f ppx_deriving_madcast.[0-9]*
	make -C test clean

.PHONY: build doc install uninstall release test clean
