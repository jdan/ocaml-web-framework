.PHONY: all test run-docker clean

all:
	ocamlbuild -I src -use-ocamlfind -libs str,unix main.native

test:
	ocamlbuild -I src -use-ocamlfind -libs str,unix test.native
	@./test.native && echo "Tests pass"

run-docker:
	docker run --rm -d -p 1337:8080 jdan/owf

clean:
	rm -rf _build/
	rm -f *.native
