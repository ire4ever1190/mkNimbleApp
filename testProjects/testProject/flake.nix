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
        pkgs = import nixpkgs {
          inherit system;
          overlays = [nimbleUtils.overlays.default];
        };
      in
      {
        packages.default = pkgs.mkNimbleApp {
          src = ./.;
          nimbleHash = "sha256-i5N+dBjw2ui+4r0ybVRtXyZ7YDWjF3kGobJyT2AJNCM=";
        };
      }
    );
}
