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

  patchPhase = ''
    export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    pushd vendor/bearssl/bearssl/certs
    # Rebuild the cacert.c file to use the users custom certs
    echo '#include <brssl.h>' > cacert.c
    ${pkgs.bearssl}/brssl ta $NIX_SSL_CERT_FILE | sed "s/static //" >> cacert.c
    # Update nix binding to point to correct amount of certificates
    taNum=$(grep "#define TAs_NUM" cacert.c | awk '{print $NF}')
    sed "s/const MozillaTrustAnchorsCount\* =.*/const MozillaTrustAnchorsCount* = $taNum/" -i cacert.nim
    cat cacert.nim
    popd
  '';

  nimbleHash = "sha256-qaoVDxcYDZJG99TwK4IR8TxBAMJKEVzSmJNyFQt52iI=";
  nativeBuildInputs = [ ];
  doCheck = false;
}
