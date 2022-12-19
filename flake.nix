# Test as eg.
#   nixos-rebuild build-vm --flake .#vimes
{
  description = "Declares my host configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  };
  outputs = { self, nixpkgs, ... }@inputs:
  let
    vimes-modules = [
      ./configuration.nix
      ./work/hardware-config/hardware-config-generated.nix
      ./work/adaptation.nix
    ];
    nixlaptop-modules = [
      ./configuration.nix
      ./hardware-configuration.nix
      ./laptop/adaptation.nix
    ];
  in rec {
    nixosConfigurations.vimes = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = vimes-modules;
    };
    nixosConfigurations.nixlaptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = nixlaptop-modules;
    };

    # Theese are for testing purposes
    nixosConfigurations.vimes-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = vimes-modules ++ [
        ({pkgs, ...}: {
          services.openssh.enable = true;
          services.openssh.permitRootLogin = "yes";
          # Give root an empty password to ssh in.
          users.extraUsers.root.password = "";
          users.mutableUsers = false;
        })
      ];
    };

    nixosConfigurations.nixlaptop-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = nixlaptop-modules ++ [
        ({pkgs, ...}: {
          services.openssh.enable = true;
          services.openssh.permitRootLogin = "yes";
          # Give root an empty password to ssh in.
          users.extraUsers.root.password = "";
          users.mutableUsers = false;
        })
      ];
    };
  };
}
