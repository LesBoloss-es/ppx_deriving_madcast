#!/bin/sh
set -e

fold_start () { printf 'travis_fold:start:%s\r\033[33;1m%s\033[0m\n' "$1" "$2"; }
fold_end () { printf 'travis_fold:end:%s\r' "$1"; }

## Initialize OPAM
export PATH=~/.local/bin:$PATH
eval `opam config env`

## Make
fold_start make 'Run `make`...'
make
fold_end make

## Run tests
fold_start tests 'Run tests...'
make test
fold_end tests

## Make install
fold_start install 'Run `make install`...'
make install
fold_end install

## Make uninstall
fold_start uninstall 'Run `make uninstall`...'
make uninstall
fold_end uninstall
