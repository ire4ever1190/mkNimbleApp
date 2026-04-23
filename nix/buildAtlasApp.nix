{ pkgs, lib }:
let
  atlasPkg = pkgs.callPackage ./atlas.nix { };
  getNimbleMetadata = pkgs.callPackage ./metadata.nix { };

  getAtlasDeps =
    {
      src,
      hash,
      ...
    }:
    pkgs.stdenv.mkDerivation {
      name = "deps";
      src = src;
      nativeBuildInputs = with pkgs; [
        atlasPkg

        git
        mercurial

        cacert
      ];
      impureEnvVars = [ "NIX_SSL_CERT_FILE" ];
      buildPhase = ''
        # https://github.com/daylinmorgan/nim2nix/blob/main/nix/build-atlas-package.nix#L53-L55
        atlas rep --verbosity:trace
        # Run install to ensure the nim.cfg is filled out (Unsure if user is meant to commit it...)
        #  atlas install --verbosity:trace
        rm -rf deps/_nimbles deps/_packages deps/atlas.config deps/atlas.cache.json
        find deps -name ".git" -type d -exec rm -rf {} +
      '';

      installPhase = ''
        mkdir $out
        cp -r deps $out/
        cp nim.cfg $out/nim.cfg
      '';

      dontFixup = true;
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = hash;
    };

in
lib.extendMkDerivation {
  constructDrv = pkgs.stdenv.mkDerivation;
  excludeDrvArgNames = [
    "atlasHash"
  ];
  extendDrvArgs =
    finalAttrs:
    args@{ ... }:
    let
      metadata = getNimbleMetadata { src = args.src; };
      atlasDeps = getAtlasDeps {
        src = args.src;
        hash = args.atlasHash;
      };
    in
    {
      pname = metadata.name;
      version = metadata.version;
      nativeBuildInputs = (args.nativeBuildInputs or [ ]) ++ [
        pkgs.nim
        atlasPkg
      ];

      buildPhase = ''
        export HOME=$(mktemp -d)

        cp -r ${atlasDeps}/deps/* deps/
        cp ${atlasDeps}/nim.cfg .

        mkdir bin

        # Find all the binary files listed
        for binary in ${builtins.concatStringsSep " " metadata.bin}; do
            nim c -o:bin/$binary -d:release ${metadata.srcDir}/$binary
        done
      '';

      installPhase = ''
        cp -r bin $out/
      '';

      # Prefill what metadata we can
      meta =
        let
          # See if we can find the license from the built in list
          license = pkgs.lib.filterAttrs (
            name: license: license ? spdxId && license.spdxId == metadata.license
          ) pkgs.lib.licenses;
        in
        {
          description = metadata.desc;
          mainProgram = builtins.elemAt metadata.bin 0;
        }
        // pkgs.lib.attrsets.optionalAttrs (builtins.length (builtins.attrNames license) == 1) {
          license = builtins.attrValues license; # Extra the license, we don't need the toplevel set
        };
    };
}
