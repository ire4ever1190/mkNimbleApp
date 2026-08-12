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
    rev = "1353ffe3b9491726f7cb148d0f21e87b9a03a666";
    hash = "sha256-L8DoKc5ngMZNGqVGySwmKzT7rxuCTPeq4Ho6Qb5ZDJY=";
  };
in
mkNimbleApp {
  src = githubSrc;
  nimbleLock = ./nimble.lock;
  nimbleHash = "sha256-WDa1w5OD49POIM78gx7ExNVaM+umdAZECxokUTRTbcY=";
  nativeBuildInputs = [
    pkgs.openssl
  ];
  doCheck = false;
}
