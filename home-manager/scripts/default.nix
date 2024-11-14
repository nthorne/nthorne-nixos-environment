{ stable, ... }:
let
  ntvim =
    with stable;
    stdenv.mkDerivation {
      name = "ntvim";
      version = "1.0";

      buildInputs = [ bash ];
      propagatedBuildInputs = [
        tmux
        neovim
        xterm
      ];

      buildCommand = ''
              mkdir -p $out/bin
              cat <<EOF > $out/bin/ntvim
        #!${bash}/bin/bash

        PATH=${lib.makeSearchPath "bin" [ tmux ]}:\$PATH
        xterm -e "tmux -2 new-session \"nvim \$*\""

        EOF
              chmod +x $out/bin/ntvim
      '';
    };
in
{
  home.packages = [
    ntvim

    (stable.callPackage ./ddoc { stable = stable; })
  ];
}
