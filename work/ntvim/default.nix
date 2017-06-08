with import <nixpkgs> { };

stdenv.mkDerivation {
  name = "ntvim";

  buildInputs = [ bash ];

  buildCommand = ''
    mkdir -p $out/bin
    cat <<EOF > $out/bin/ntvim
#!${bash}/bin/bash

xterm -e "tmux -2 new-session \"nvim \$*\""

EOF
    chmod +x $out/bin/ntvim
  '';
}
