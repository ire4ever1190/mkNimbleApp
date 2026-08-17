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
        pkgs = import nixpkgs {
          inherit system;
          overlays = [nimbleUtils.overlays.default];
        };
      in
      {
        packages.default = pkgs.mkNimbleApp {
          src = ./.;
          nimbleHash = "sha256-qaoVDxcYDZJG99TwK4IR8TxBAMJKEVzSmJNyFQt52iI=";
        };
      }
    );
}
