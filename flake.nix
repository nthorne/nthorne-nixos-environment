# Test as eg.
#   nixos-rebuild build-vm --flake .#vimes-vm
{
  description = "Declares my host configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nthorne-zsh = {
      url = "github:nthorne/nthorne-zsh-environment";
      flake = false;
    };

    nixvim.url = "github:nix-community/nixvim";

    stylix.url = "github:danth/stylix/release-24.11";

    sops-nix.url = "github:Mic92/sops-nix";

    nix-secrets.url = "git+ssh://git@github.com/nthorne/nix-secrets.git?allRefs=true&ref=main";

    # TODO:: Check if this is fixed, or see if I can fix it.
    # Pin this one since fec8c2d75fcf42f657247cab43cd01cfea6095ea
    # fails on require-check.
    mcphub-nvim.url = "github:ravitemer/mcphub.nvim?rev=c737d9df6d3a86d0e063bed7a81270bb27f0bd3c";
    mcp-hub.url = "github:ravitemer/mcp-hub";
  };
  outputs = {
    nixpkgs,
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
          nixpkgs-unstable.flake = nixpkgs;
        };
      };
    };

    system = "x86_64-linux";

    vimes-modules = [
      ./configuration.nix
      ./work/hardware-config/hardware-config-generated.nix
      ./work/adaptation.nix

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

        # Mako fails to build on main, so I disable it for now.
        home-manager.sharedModules = [
          {
            stylix.autoEnable = true;
            stylix.targets = {
              mako.enable = false;
              wpaperd.enable = false;
              vscode.enable = false;
            };
          }
        ];
      }

      sops-nix.nixosModules.sops
    ];

    nixlaptop-modules = [
      ./configuration.nix
      ./laptop/hardware-configuration.nix
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

        # Mako fails to build on main, so I disable it for now.
        home-manager.sharedModules = [
          {
            stylix.autoEnable = true;
            stylix.targets.mako.enable = false;
          }
        ];
      }
    ];

    hex-modules = [
      ./configuration.nix
      ./hex/hardware-configuration.nix
      ./hex/adaptation.nix

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
            hostname = "hex";
            system = "${system}";
          };

        # Mako fails to build on main, so I disable it for now.
        home-manager.sharedModules = [
          {
            stylix.autoEnable = true;
            stylix.targets.mako.enable = false;
          }
        ];
      }
    ];

    wifiDevice = "wlp0s20f3";
  in {
    nixpkgs.config.allowUnfree = true;

    formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;

    nixosConfigurations.vimes = nixpkgs.lib.nixosSystem {
      system = "${system}";
      modules = vimes-modules;
    };
    nixosConfigurations.nixlaptop = nixpkgs.lib.nixosSystem {
      system = "${system}";
      modules = nixlaptop-modules;
    };
    nixosConfigurations.hex = nixpkgs.lib.nixosSystem {
      system = "${system}";
      modules = hex-modules;
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
