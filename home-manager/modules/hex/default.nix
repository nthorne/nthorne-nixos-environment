{flake-inputs, ...}: let
  secretsFolders = builtins.toString flake-inputs.nix-secrets;
in {
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
