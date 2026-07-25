{
  description = "Basic nimble application";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nimbleUtils = {
      url = "path:../../";
      inputs.nixpkgs.follows = "nixpkgs";
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
          atlasHash = "sha256-S04VO3V72xPZwlt7aM+z1av3Q5TreZmYqwBt+a11d44=";
        };
      }
    );
}
