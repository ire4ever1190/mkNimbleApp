# Derivation for atlas
{
  pkgs,
  lib,
  fetchFromGitHub,
}:
let
  githubSrc = fetchFromGitHub {
    owner = "ire4ever1190";
    repo = "atlas";
    rev = "1353ffe3b9491726f7cb148d0f21e87b9a03a666";
    hash = "sha256-L8DoKc5ngMZNGqVGySwmKzT7rxuCTPeq4Ho6Qb5ZDJY=";
  };
in
pkgs.mkNimbleApp {
  src = githubSrc;
  nimbleLock = ./nimble.lock;
  nimbleHash = "sha256-VbLYrwjILBOt+cW8eqUdwSL6z6exaJWJ9wJXrToAhf4=";
  nativeBuildInputs = [
    pkgs.openssl
  ];
  doCheck = false;
}
