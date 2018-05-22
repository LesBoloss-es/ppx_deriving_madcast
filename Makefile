build:
	jbuilder build @install

doc:
	jbuilder build @doc

install:
	jbuilder install

uninstall:
	jbuilder uninstall

test:
	jbuilder runtest

clean:
	jbuilder clean

.PHONY: build doc install uninstall test clean
