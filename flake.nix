# Test as eg.
#   nixos-rebuild build-vm --flake .#vimes-vm
{
  description = "Declares my host configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nthorne-zsh = {
      url = "github:nthorne/nthorne-zsh-environment";
      flake = false;
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
      # url = "github:nix-community/nixvim/nixos-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix/release-24.11";

    sops-nix.url = "github:Mic92/sops-nix";

    nix-secrets.url = "git+ssh://git@github.com/nthorne/nix-secrets.git?allRefs=true&ref=main";
  };
  outputs = {
    self,
    nixpkgs,
    unstable,
    home-manager,
    stylix,
    sops-nix,
    ...
  } @ inputs: let
    # Pin nixpkgs in the flake registry to what we use for the system
    pin-registries = {...}: {
      nix = {
        registry = {
          nixpkgs.flake = nixpkgs;
          nixpkgs-unstable.flake = unstable;
        };
      };
    };

    pkgs-unstable = import unstable {
      inherit system;
      config.allowUnfree = true;
    };

    system = "x86_64-linux";

    vimes-modules = [
      ./configuration.nix
      ./work/hardware-config/hardware-config-generated.nix
      ./work/adaptation.nix
      {
        _module.args = {
          unstable = pkgs-unstable;
        };
      }

      stylix.nixosModules.stylix

      pin-registries

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.nthorne = import ./home-manager/home.nix;
        home-manager.extraSpecialArgs.flake-inputs =
          inputs
          // {
            hostname = "vimes";
            system = "${system}";
          };
      }

      sops-nix.nixosModules.sops
    ];

    nixlaptop-modules = [
      ./configuration.nix
      ./hardware-configuration.nix
      ./laptop/adaptation.nix

      stylix.nixosModules.stylix

      pin-registries

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.nthorne = import ./home-manager/home.nix;
        home-manager.extraSpecialArgs.flake-inputs =
          inputs
          // {
            hostname = "nixlaptop";
            system = "${system}";
          };
      }
    ];

    wifiDevice = "wlp0s20f3";
  in {
    formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;

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

      modules =
        vimes-modules
        ++ [
          (
            {...}: {
              #services.openssh.enable = true;
              #services.openssh.permitRootLogin = "yes";
              #users.extraUsers.root.password = "";

              users.extraUsers."nthorne".password = "nthorne";
              users.mutableUsers = false;

              systemd.services = {
                "network-link-${wifiDevice}".wantedBy = nixpkgs.lib.mkForce [];
                "network-addresses-${wifiDevice}".wantedBy = nixpkgs.lib.mkForce [];
              };
            }
          )
        ];
    };

    nixosConfigurations.nixlaptop-vm = nixpkgs.lib.nixosSystem {
      system = system;

      modules =
        nixlaptop-modules
        ++ [
          (
            {...}: {
              #services.openssh.enable = true;
              #services.openssh.permitRootLogin = "yes";
              #users.extraUsers.root.password = "";

              users.extraUsers."nthorne".password = "nthorne";
              users.mutableUsers = false;
            }
          )
        ];
    };
  };
}
