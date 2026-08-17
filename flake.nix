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
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import ./overlay.nix)
          ];
        };
      in
      {
        packages = {
          mkNimbleApp = pkgs.mkNimbleApp;
          buildAtlasApp = pkgs.buildAtlasApp;
          atlas = pkgs.atlas;
          nimble = pkgs.nimble;
        };
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
