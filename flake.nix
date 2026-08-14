{
  description = "Wrapper for binary nimble projects";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  # Flake outputs
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = {
            mkNimbleApp = pkgs.callPackage nix/nimble.nix { };
            buildAtlasApp = pkgs.callPackage nix/buildAtlasApp.nix { };
          };
          atlas = pkgs.callPackage nix/pkgs/atlas.nix { };
          nimble = pkgs.callPackage nix/pkgs/nimble.nix { };
        };
        formatter = pkgs.nixfmt-rfc-style;
      }
    )
    // {
      templates = {
        basic = {
          path = ./templates/basic;
          description = "Basic template for wrapping a nimble app";
        };
        default = self.templates.basic;
      };
    };
}
