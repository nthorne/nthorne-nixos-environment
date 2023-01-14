# Test as eg.
#   nixos-rebuild build-vm --flake .#vimes-vm
{
  description = "Declares my host configurations";

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
  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
  let
    system = "x86_64-linux";
    vimes-modules = [
      ./configuration.nix
      ./work/hardware-config/hardware-config-generated.nix
      ./work/adaptation.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.nthorne = import ./home-manager/home.nix;
        home-manager.extraSpecialArgs.flake-inputs = inputs // {hostname="vimes";system="${system}";};
      }
    ];
    nixlaptop-modules = [
      ./configuration.nix
      ./hardware-configuration.nix
      ./laptop/adaptation.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.nthorne = import ./home-manager/home.nix;
        home-manager.extraSpecialArgs.flake-inputs = inputs // {hostname="nixlaptop";system="${system}";};
      }
    ];
    wifiDevice = "wlp0s20f3";
  in rec {
    nixosConfigurations.vimes = nixpkgs.lib.nixosSystem {
      system = "${system}";
      modules = vimes-modules;
    };
    nixosConfigurations.nixlaptop = nixpkgs.lib.nixosSystem {
      system = "${system}";
      modules = nixlaptop-modules;
    };

    # Theese are for testing purposes
    nixosConfigurations.vimes-vm = nixpkgs.lib.nixosSystem {
      system = system;

      modules = vimes-modules ++ [
        ({pkgs, ...}: {
          #services.openssh.enable = true;
          #services.openssh.permitRootLogin = "yes";
          #users.extraUsers.root.password = "";

          users.extraUsers."nthorne".password = "nthorne";
          users.mutableUsers = false;

          systemd.services = {
            "network-link-${wifiDevice}".wantedBy = nixpkgs.lib.mkForce [];
            "network-addresses-${wifiDevice}".wantedBy = nixpkgs.lib.mkForce [];
          };
        })
      ];
    };

    nixosConfigurations.nixlaptop-vm = nixpkgs.lib.nixosSystem {
      system = system;

      modules = nixlaptop-modules ++ [
        ({pkgs, ...}: {
          #services.openssh.enable = true;
          #services.openssh.permitRootLogin = "yes";
          #users.extraUsers.root.password = "";

          users.extraUsers."nthorne".password = "nthorne";
          users.mutableUsers = false;
        })
      ];
    };
  };
}
