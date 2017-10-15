.PHONY: all test clean

all:
	ocamlbuild -use-ocamlfind -libs str,unix main.native

test:
	ocamlbuild -use-ocamlfind -libs str,unix test.native
	./test.native

clean:
	rm -rf _build/
	rm -f *.native
