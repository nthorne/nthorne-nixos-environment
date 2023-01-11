{
  description = "My Home Manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nthorne-tmux = {
      url = "github:nthorne/nthorne-tmux-environment";
      flake = false;
    };
    nthorne-xmonad = {
      url = "github:nthorne/nthorne-xmonad-environment";
      flake = false;
    };
    nthorne-zsh = {
      url = "github:nthorne/nthorne-zsh-environment";
      flake = false;
    };
  };

  outputs = {self, nixpkgs, home-manager, ...}@inputs:
  let
    mkHome = {hostname}@argSet: inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home.nix ];

      # Pass the inputs attribute set to home.nix
      extraSpecialArgs.flake-inputs = inputs // argSet;
    };
  in {
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

    homeConfigurations = {
      "nthorne@vimes" = mkHome {hostname="vimes";};

      "nthorne@nixlaptop" = mkHome {hostname="nixlaptop";};
    };
  };
}
