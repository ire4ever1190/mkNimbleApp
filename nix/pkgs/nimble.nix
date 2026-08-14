# Derivation for atlas
{
  pkgs,
}:
pkgs.nimble.overrideAttrs (old: {
  patchPhase = ''
    # Check if we need to update bearssl to include user certificates
    if [ -f $NIX_SSL_CERT_FILE ]; then
        pushd vendor/bearssl/bearssl/certs
        # Rebuild the cacert.c file to use the users custom certs
        echo '#include <brssl.h>' > cacert.c
        ${pkgs.bearssl}/brssl ta $NIX_SSL_CERT_FILE | sed "s/static //" >> cacert.c
        # Update nix binding to point to correct amount of certificates
        taNum=$(grep "#define TAs_NUM" cacert.c | awk '{print $NF}')
        sed "s/const MozillaTrustAnchorsCount\* =.*/const MozillaTrustAnchorsCount* = $taNum/" -i cacert.nim
        cat cacert.nim
        popd
    fi
  '';
})
