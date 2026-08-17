{ pkgs }:

let
  getNimbleMetadata = pkgs.callPackage ./metadata.nix { };

  # Function that creates a derivation containing the dependencies for a nimble project.
  # Can be copied into a folder called `nimbledeps` inside a project to give it isolated dependencies
  getNimbleDeps =
    {
      src,
      hash,
      ...
    }:
    pkgs.stdenv.mkDerivation {
      name = "deps";
      src = src;
      nativeBuildInputs = with pkgs; [
        nimble
        # Needed for downloading different packages
        git
        mercurial

        jq
        cacert
      ];
      impureEnvVars = [ "NIX_SSL_CERT_FILE" ];
      buildPhase = ''
        # Nimble needs an actual home folder
        export HOME=$(mktemp -d)
        mkdir -p nimbledeps

        # Run setup to pull all the dependencies
        nimble --useSystemNim setup

        # Sometimes the files listed in each nimblemeta.json file is in a different order.
        # We'll sort that so the hash is consistent
        for file in $(find -name nimblemeta.json); do
          jq '.metaData.files |= sort' "$file" > "$file.tmp"
          mv "$file.tmp" "$file"
        done

        # Clear out other files that can change the hash
        cd nimbledeps
        rm -f official-nim-releases.json packages_temp.json packages_official.json
        cd ..

        # The reverseDeps in the meta refences the current source path.
        # This means that any change (including updating the flake) will update the hash.
        # Couldn't replicate in tests, but noticed it manually.
        # So anyways, we replace the current working directory with just a static `/project`
        sed -i s@$(pwd)@/project@g nimbledeps/nimbledata2.json
      '';

      installPhase = ''
        cp -r nimbledeps $out
      '';

      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = hash;
    };
in
userArgs:
let
  src =
    if userArgs ? nimbleLock then
      pkgs.runCommand "src-with-lock" { } ''
        cp -r ${userArgs.src} $out
        chmod +w $out
        cp ${userArgs.nimbleLock} $out/nimble.lock
      ''
    else
      userArgs.src;
  metadata = getNimbleMetadata { inherit src; };
  deps = getNimbleDeps {
    inherit src;
    hash = userArgs.nimbleHash;
  };
  defaultNativeBuildInputs = with pkgs; [
    nimble
    nim
    deps
  ];
  mergedNativeBuildInputs = defaultNativeBuildInputs ++ (userArgs.nativeBuildInputs or [ ]);

  userArgsWithoutNativeBuildInputs = builtins.removeAttrs userArgs [
    "nativeBuildInputs"
    "nimbleLock"
    "nimbleHash"
    "src"
  ];

  setupNimbleDir = ''
    # Nimble likes to update the nimbledata2.json file, so we need a writable dir.
    # Only nimbledata2.json actually needs to be writable though, so we symlink the
    # bulk of the deps (pkgs2) from the store instead of copying the whole tree.
    # Note: this makes pkgs2 read-only, so ad-hoc `nimble install` in the shell will
    # fail — deps are meant to come from the flake, not manual installs.
    export NIMBLE_DIR=$(mktemp -d)
    ln -s ${deps}/pkgs2 $NIMBLE_DIR/pkgs2
    # Copy is read-only from the store; nimble writes to this file, so make it writable
    cp ${deps}/nimbledata2.json $NIMBLE_DIR/nimbledata2.json
    chmod +w $NIMBLE_DIR/nimbledata2.json

    # Create empty files to stop nimble from trying to download them
    echo "[]" > $NIMBLE_DIR/packages_official.json
    echo "[]" > $NIMBLE_DIR/official-nim-releases.json
  '';
in
pkgs.stdenv.mkDerivation (
  {
    pname = (metadata.name);
    version = metadata.version;
    nativeBuildInputs = mergedNativeBuildInputs;
    src = src;
    shellHook = ''
      ${setupNimbleDir}

      # Generate nimble.paths from what's actually in the store (editor/LSP support)
      {
        echo "--noNimblePath"
        # Add each pkg as a path
        find -L ${deps}/pkgs2/ -maxdepth 1 -type d | tail -n +2 | while read dir; do
          echo "--path:\"$dir\""
        done
      } > nimble.paths
    '';
    buildPhase = ''
      runHook preBuild

      ${setupNimbleDir}
      export NIMBLE_ARGS="--useSystemNim --nim:${pkgs.nim}/bin/nim --nimcache:$(mktemp -d)"

      nimble $NIMBLE_ARGS -d:release build

      runHook postBuild
    '';

    doCheck = true;
    checkPhase = ''
      runHook preCheck

      nimble $NIMBLE_ARGS test

      runHook postCheck
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin/
      if [ -n "${metadata.binDir}" ]; then
          cd ${metadata.binDir}
      fi

      # Find all the binary files listed
      for binary in ${builtins.concatStringsSep " " metadata.bin}; do
          mv $binary $out/bin/$binary
      done

      runHook postInstall
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
  }
  // userArgsWithoutNativeBuildInputs
)
