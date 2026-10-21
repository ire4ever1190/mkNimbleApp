final: prev: {
  mkNimbleApp = final.callPackage nix/nimble.nix { };
  buildAtlasApp = prev.callPackage nix/buildAtlasApp.nix { };
  atlas = prev.nim-atlas;
  nimble = prev.nimble.overrideAttrs (finalAttrs: prevAttrs: {
    # Use the latest commit from the nimble repo instead of the tagged release
    src = prev.fetchFromGitHub {
      owner = "nim-lang";
      repo = "nimble";
      rev = "14a40c207f37e08a6b2e4106531cc0c0bc092576";
      hash = "sha256-f2fmtFhNCTjE5OaM7xID18sYfAFQhZkT/uLqoxiaUyM=";
      fetchSubmodules = true;
    };
    # nixpkgs' nimble package interpolates `finalAttrs.src.tag` into nimFlags;
    # our src is fetched by rev so there is no tag attr.
    nimFlags = [ "--define:git_revision_override=14a40c207f37e08a6b2e4106531cc0c0bc092576" ];

    # Attribute of the certificate. Allows user to override it (e.g. for internal company certs)
    cacert = prevAttrs.cacert or final.cacert;

    patchPhase = ''
      pushd vendor/bearssl/bearssl/certs
      # Rebuild the cacert.c file to use the users custom certs
      echo '#include <brssl.h>' > cacert.c
      ${final.bearssl}/brssl ta ${finalAttrs.cacert}/etc/ssl/certs/ca-bundle.crt | sed "s/static //" >> cacert.c
      # Update nix binding to point to correct amount of certificates
      taNum=$(grep "#define TAs_NUM" cacert.c | awk '{print $NF}')
      sed "s/const MozillaTrustAnchorsCount\* =.*/const MozillaTrustAnchorsCount* = $taNum/" -i cacert.nim
      popd
    '';
  });
}
