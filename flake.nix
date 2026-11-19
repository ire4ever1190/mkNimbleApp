{
  description = "Wrapper for binary nimble projects";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
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
            self.overlays.default
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
      overlays.default = import ./overlay.nix;
      templates = {
        basic = {
          path = ./templates/basic;
          description = "Basic template for wrapping a nimble app";
        };
        default = self.templates.basic;
      };
    };
}
