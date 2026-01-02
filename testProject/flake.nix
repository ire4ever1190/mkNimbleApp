{
  description = "Basic nimble application";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nimbleUtils = {
      url = "path:../";
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
        mkNimbleApp = nimbleUtils.packages.${system}.default.mkNimbleApp;
      in
      {
        packages.default = mkNimbleApp {
          src = ./.;
          nimbleHash = "sha256-9meBcyeRgceZlZnipacFke+41ZKw7jh94JxqoaUGmXE=";
        };
      }
    );
}
