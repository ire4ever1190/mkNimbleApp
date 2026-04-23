# Derivation for atlas
{
  pkgs,
  lib,
  fetchFromGitHub,
}:
let
  mkNimbleApp = pkgs.callPackage ./nimble.nix { };
  githubSrc = fetchFromGitHub {
    owner = "ire4ever1190";
    repo = "atlas";
    rev = "83cfc9ab7d75a9c0d628adfd064b4d1d3d421b8f";
    hash = "sha256-gc/GM9GnMvhFRpOeMNrW+fHDts8FfCoF/J+sFgVKWGE=";
  };
in
mkNimbleApp {
  src = githubSrc;
  nimbleLock = ./nimble.lock;
  nimbleHash = "sha256-c8dSGPDLbmkB61W2hTn4T/w4DR+IQ7UD6g8QBYn/7xQ=";
  nativeBuildInputs = [
    pkgs.openssl
  ];
  doCheck = false;
}
