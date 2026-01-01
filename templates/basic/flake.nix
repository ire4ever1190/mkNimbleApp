{
  description = "Basic nimble application";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nimbleUtils = {
      url = "github:ire4ever1190/mkNimbleApp";
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
          nimbleHash = "";
        };
      }
    );
}
