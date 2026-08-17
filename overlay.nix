final: prev: {
  mkNimbleApp = final.callPackage nix/nimble.nix { };
  buildAtlasApp = prev.callPackage nix/buildAtlasApp.nix { };
  atlas = prev.callPackage nix/pkgs/atlas.nix { };
  nimble = prev.nimble.overrideAttrs (final: prev: {
    # Attribute of the certificate. Allows user to override it (e.g. for internal company certs)
    cacert = pkgs.cacert;

    patchPhase = ''
      pushd vendor/bearssl/bearssl/certs
      # Rebuild the cacert.c file to use the users custom certs
      echo '#include <brssl.h>' > cacert.c
      ${pkgs.bearssl}/brssl ta ${final.cacert}/etc/ssl/certs/ca-bundle.crt | sed "s/static //" >> cacert.c
      # Update nix binding to point to correct amount of certificates
      taNum=$(grep "#define TAs_NUM" cacert.c | awk '{print $NF}')
      sed "s/const MozillaTrustAnchorsCount\* =.*/const MozillaTrustAnchorsCount* = $taNum/" -i cacert.nim
      ca cacert.nim
      popd
    '';
  });
}
