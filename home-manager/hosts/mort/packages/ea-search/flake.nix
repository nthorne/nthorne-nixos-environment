# For local development
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ea-search = pkgs.callPackage ../ea-search.nix { };
      in
      {
        packages = {
          default = ea-search;
          inherit ea-search;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            rustup
            pkg-config
          ];
          buildInputs = with pkgs; [
            sqlite
          ];
        };
      }
    );
}
