.PHONY: all

all:
	ocamlbuild -libs str,unix main.native
