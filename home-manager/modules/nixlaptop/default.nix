{
  pkgs,
  flake-inputs,
  ...
} @ args: let
  secretsFolders = builtins.toString flake-inputs.nix-secrets;
in {
  imports = [
    (import ../workstation.nix args)
    flake-inputs.sops-nix.homeManagerModules.sops
  ];

  home.packages = with pkgs; [
    bashmount
    calibre
    deluge
    sshfs-fuse
    vlc
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
