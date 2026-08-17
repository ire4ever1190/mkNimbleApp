final: prev: {
  mkNimbleApp = prev.callPackage nix/nimble.nix { };
  buildAtlasApp = prev.callPackage nix/buildAtlasApp.nix { };
  atlas = prev.callPackage nix/pkgs/atlas.nix { };
  nimble = prev.callPackage nix/pkgs/nimble.nix { };
}
