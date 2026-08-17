{
  description = "Wrapper for binary nimble projects";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  # Flake outputs
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    {
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
