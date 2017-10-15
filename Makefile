.PHONY: all test

all:
	ocamlbuild -use-ocamlfind -libs str,unix main.native

test:
	ocamlbuild -use-ocamlfind -libs str,unix test.native
	./test.native
