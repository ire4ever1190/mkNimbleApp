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
        rm deps/_nimbles deps/_packages deps/atlas.config atlas.cache.json -rf
        find deps -name ".git" -type d -exec rm -rf {} +
      '';

      installPhase = ''
        mkdir $out
        cp -r deps $out/
        cp nim.cfg $out/nim.cfg
      '';

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

        cp -r ${atlasDeps}/deps deps
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
    };
}
