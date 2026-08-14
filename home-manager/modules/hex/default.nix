{ flake-inputs, ... }:
let
  secretsFolders = builtins.toString (import ../../lib/nix-secrets.nix);
in
{
  imports = [
    flake-inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "/home/nthorne/.config/sops/age/keys.txt";
    defaultSopsFile = "${secretsFolders}/secrets.yaml";

    secrets = {
      "all/atuin/key".path = "/home/nthorne/.local/share/atuin/key";
      "all/atuin/session".path = "/home/nthorne/.local/share/atuin/session";
    };
  };
}
