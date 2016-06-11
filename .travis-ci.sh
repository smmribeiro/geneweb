set -uex

# Install packages dependencies
export OPAMYES=1
eval $(opam config env)
opam install ocamlfind camlp5 depext
opam depext -i lablgtk

# Build GeneWeb
./configure
make everything
make distrib
