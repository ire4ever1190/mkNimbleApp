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
    rev = "0.10.1";
    hash = "sha256-WUnPvwsZ0IiDU3WhOQBUf2zT47jUFkZ0Kxn4oxWqdSU=";
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
