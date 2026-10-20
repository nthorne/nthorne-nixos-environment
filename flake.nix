# Test as eg.
#   nixos-rebuild build-vm --flake .#vimes-vm
{
  description = "Declares my host configurations";

  nixConfig = {
    extra-trusted-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:nix-community/nixvim";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-secrets.url = "git+ssh://git@github.com/nthorne/nix-secrets.git?allRefs=true&ref=main";

    mcphub-nvim = {
      url = "github:ravitemer/mcphub.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mcp-hub = {
      url = "github:ravitemer/mcp-hub";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/nixos-wsl/main";

    robotcode.url = "path:./home-manager/packages/robotcode/";
  };
  outputs =
    {
      nixpkgs,
      home-manager,
      stylix,
      sops-nix,
      nixos-wsl,
      ...
    }@inputs:
    let
      # Pin nixpkgs in the flake registry to what we use for the system
      pin-registries = _: {
        nix = {
          registry = {
            nixpkgs.flake = nixpkgs;
            nixpkgs-unstable.flake = nixpkgs;
          };
        };
      };

      system = "x86_64-linux";

      # These are modules that are common across all my systems.
      common-modules = [
        ./nix-settings.nix
        stylix.nixosModules.stylix
        pin-registries
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.nthorne = import ./home-manager/home.nix;

            sharedModules = [
              {
                stylix.autoEnable = true;
              }
            ];
          };
        }
      ];

      mkHostModules = { hostname, hostModule, extraModules ? [ ] }: common-modules ++ [ hostModule ] ++ extraModules ++ [{
        home-manager.extraSpecialArgs.flake-inputs = inputs // {
          inherit hostname system;
        };
      }];

      vimes-modules = mkHostModules {
        hostname = "vimes";
        hostModule = ./configuration.nix;
        extraModules = [
          ./vimes/hardware-config/hardware-config-generated.nix
          ./desktop.nix
          ./vimes/adaptation.nix
          sops-nix.nixosModules.sops
        ];
      };

      nixlaptop-modules = mkHostModules {
        hostname = "nixlaptop";
        hostModule = ./configuration.nix;
        extraModules = [
          ./laptop/adaptation.nix
          ./laptop/hardware-configuration.nix
          ./desktop.nix
        ];
      };

      hex-modules = mkHostModules {
        hostname = "hex";
        hostModule = ./configuration.nix;
        extraModules = [
            ./hex/adaptation.nix
            ./hex/hardware-configuration.nix
        ];
      };

      mort-modules = mkHostModules {
        hostname = "mort";
        hostModule = ./mort/adaptation.nix;
      };

      wifiDevice = "wlp0s20f3";

      mkConfig =
        {
          name,
          modules,
        }:
        {
          "${name}" = nixpkgs.lib.nixosSystem {
            system = "${system}";
            modules = modules;
          };
        };

      mkVmConfig =
        {
          name,
          modules,
          extraModules ? [ ],
        }:
        {
          "${name}-vm" = nixpkgs.lib.nixosSystem {
            system = "${system}";

            modules =
              modules
              ++ [
                (_: {
                  users.users."nthorne".password = "nthorne";
                  users.mutableUsers = false;
                })
              ]
              ++ extraModules;
          };
        };
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;

      nixosConfigurations =
        mkConfig {
          name = "vimes";
          modules = vimes-modules;
        }
        // mkConfig {
          name = "nixlaptop";
          modules = nixlaptop-modules;
        }
        // mkConfig {
          name = "hex";
          modules = hex-modules;
        }
        // {
          "mort" = nixpkgs.lib.nixosSystem {
            system = "${system}";
            specialArgs = { inherit nixos-wsl; };
            modules = mort-modules;
          };
        }
        // mkVmConfig {
          name = "vimes";
          modules = vimes-modules;
          extraModules = [
            (_: {
              systemd.services = {
                "network-link-${wifiDevice}".wantedBy = nixpkgs.lib.mkForce [ ];
                "network-addresses-${wifiDevice}".wantedBy = nixpkgs.lib.mkForce [ ];
              };
            })
          ];
        }
        // mkVmConfig {
          name = "nixlaptop";
          modules = nixlaptop-modules;
        };
    };
}
