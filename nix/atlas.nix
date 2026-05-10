# Derivation for atlas
{
  pkgs,
  lib,
  fetchFromGitHub,
}:
let
  mkNimbleApp = pkgs.callPackage ./nimble.nix { };
  githubSrc = fetchFromGitHub {
    owner = "nim-lang";
    repo = "atlas";
    rev = "f30ab53af136e70d19c6dacd05d49f087f8dab88";
    hash = "sha256-dAOtcjY1aYDbRRSYqOgwq8efEpdEwG9PTKcOc6l2MEI=";
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
