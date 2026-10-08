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
      nixpkgs,
      ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nimbleUtils.overlays.default ];
        };
      in
      {
        packages.default = pkgs.mkNimbleApp {
          src = ./.;
          # Update this hash after first run
          nimbleHash = "";
        };
      }
    );
}
