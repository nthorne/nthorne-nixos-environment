{ stable, stdenv, ... }:
let
  plantuml-filter = import ./plantumlfilter;
in
stdenv.mkDerivation {
  name = "ddoc";

  buildInputs = with stable; [
    bash
    texlive.combined.scheme-small
    pandoc
    plantuml-filter
  ];

  buildCommand = with stable; ''
        mkdir -p $out/bin
        cat <<EOT > $out/bin/ddoc
    #!${bash}/bin/bash

    PATH=${texlive.combined.scheme-small}/bin:$PATH

    ${pandoc}/bin/pandoc --filter ${plantuml-filter}/bin/plantuml.py \$@
    EOT
        chmod +x $out/bin/ddoc
  '';
}
