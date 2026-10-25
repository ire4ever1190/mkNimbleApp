{
  description = "Wrapper for binary nimble projects";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # needed for bearssl
    nixpkgs-old.url = "github:nixos/nixpkgs?ref=nixos-25.11";
  };
  # Flake outputs
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nixpkgs-old,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              bearssl = nixpkgs-old.legacyPackages.${system}.bearssl;
            })
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
