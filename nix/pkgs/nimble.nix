# Derivation for atlas
{
  pkgs,
  lib,
  fetchFromGitHub,
}:
let
  mkNimbleApp = pkgs.callPackage ../nimble.nix { };
in
mkNimbleApp rec {
  version = "0.24.1";
  src = fetchFromGitHub {
    owner = "nim-lang";
    repo = "nimble";
    rev = "v${version}";
    hash = "sha256-39d9EsS0opz6vQzSE91gBRQbaTPeebVQLf/QdJoaD8o=";
    fetchSubmodules = true;
  };
  nimbleHash = "sha256-qaoVDxcYDZJG99TwK4IR8TxBAMJKEVzSmJNyFQt52iI=";
  nativeBuildInputs = [ ];
  doCheck = false;
}
