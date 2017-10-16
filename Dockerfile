FROM ocaml/opam
MAINTAINER Jordan Scales <scalesjordan@gmail.com>

USER opam

RUN opam install ocamlfind

RUN mkdir webapp
ADD Makefile webapp/
ADD main.ml webapp/
ADD src webapp/src/
WORKDIR webapp/

RUN eval `opam config env` && make

EXPOSE 8080

CMD [ "./main.native" ]
