build:
	jbuilder build @install

install:
	jbuilder install

test:
	jbuilder build test/test_ppx_deriving_madcast.exe
	_build/default/test/test_ppx_deriving_madcast.exe

clean:
	jbuilder clean

.PHONY: build install test clean
