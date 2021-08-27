{ pkgs, ... }:
let
  splitter = pkgs.writeShellScriptBin "splitter" (builtins.readFile ./splitter);

  aosp = pkgs.writeShellScriptBin "aosp" (builtins.readFile ./aosp);

  ntvim = with pkgs; stdenv.mkDerivation {
    name = "ntvim";
    version = "1.0";

    buildInputs = [ bash ];
    propagatedBuildInputs = [ tmux neovim xterm ];

    buildCommand = ''
      mkdir -p $out/bin
      cat <<EOF > $out/bin/ntvim
#!${bash}/bin/bash

PATH=${lib.makeSearchPath "bin" [tmux]}:\$PATH
xterm -e "tmux -2 new-session \"nvim \$*\""

EOF
      chmod +x $out/bin/ntvim
    '';
  };
in
{
  home.packages = [
    aosp
    ntvim
    splitter

    (pkgs.callPackage ./ddoc {pkgs=pkgs;})
  ];
}
