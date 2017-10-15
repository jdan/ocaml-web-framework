.PHONY: all test clean

all:
	ocamlbuild -I src -use-ocamlfind -libs str,unix main.native

test:
	ocamlbuild -I src -use-ocamlfind -libs str,unix test.native
	@./test.native && echo "Tests pass"

clean:
	rm -rf _build/
	rm -f *.native
