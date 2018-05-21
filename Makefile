build:
	jbuilder build @install

doc:
	jbuilder build @doc

install:
	jbuilder install

uninstall:
	jbuilder uninstall

test: build
	jbuilder build .ppx/ppx_deriving_madcast/ppx.exe
	make -C test

clean:
	jbuilder clean
	make -C test clean

.PHONY: build doc install uninstall test clean
