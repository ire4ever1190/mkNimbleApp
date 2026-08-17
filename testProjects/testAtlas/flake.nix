{
  description = "Basic nimble application";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nimbleUtils = {
      url = "path:../../";
    };
  };
  outputs =
    {
      flake-utils,
      nimbleUtils,
      nixpkgs,
      ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [nimbleUtils.overlays.default];
        };
      in
      {
        packages.default = pkgs.buildAtlasApp {
          src = ./.;
          atlasHash = "sha256-kHgi0P0GcfOE3MmhriYt3j4vZ7DccIGik6f92uEAvoM=";
        };
      }
    );
}
