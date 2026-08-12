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
      ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        buildAtlasApp = nimbleUtils.packages.${system}.default.buildAtlasApp;
      in
      {
        packages.default = buildAtlasApp {
          src = ./.;
          atlasHash = "sha256-kHgi0P0GcfOE3MmhriYt3j4vZ7DccIGik6f92uEAvoM=";
        };
      }
    );
}
