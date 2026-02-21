{ pkgs }:
let
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
        mkdir -p nimbledeps

        # Run setup to pull all the dependencies. The solver is set to legacy to get around a bug
        # where nimble tries to install Nim when there are no dependencies since it thinks there
        # are no locked dependencies
        nimble --useSystemNim --solver:legacy --debug setup

        # Sometimes the files listed in each nimblemeta.json file is in a different order.
        # We'll sort that so the hash is consistent
        for file in $(find -name nimblemeta.json); do
          jq '.metaData.files |= sort' "$file" > "$file.tmp"
          mv "$file.tmp" "$file"
        done
      '';

      installPhase = ''
        cp -r nimbledeps $out
      '';

      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = hash;
    };

  # Returns the output of `nimble dump` in a structured format
  getNimbleMetadata =
    { src }:
    builtins.fromJSON (
      builtins.readFile (
        pkgs.stdenv.mkDerivation {
          name = "metadata";
          nativeBuildInputs = with pkgs; [
            nimble
            jq
          ];
          src = src;
          installPhase = ''
            # We need to delete nimDir since it refers to a store path
            nimble -l --offline dump --json --silent | jq 'del(.nimDir)' > $out
          '';
        }
      )
    );
in
{
  mkNimbleApp =
    userArgs:
    let
      metadata = getNimbleMetadata { src = userArgs.src; };
      deps = getNimbleDeps {
        src = userArgs.src;
        hash = userArgs.nimbleHash;
      };
    in
    let
      defaultNativeBuildInputs = with pkgs; [
        nimble
        nim
        deps
      ];
      mergedNativeBuildInputs = defaultNativeBuildInputs ++ (userArgs.nativeBuildInputs or [ ]);
      userArgsWithoutNativeBuildInputs = builtins.removeAttrs userArgs [ "nativeBuildInputs" ];

      setupNimbleDir = ''
        # Copy into a temp directory we can write to. Nimble likes to update the nimbledata2.json file
        export NIMBLE_DIR=$(mktemp -d)
        cp -r ${deps}/* $NIMBLE_DIR
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
        shellHook = ''
          # Create the local deps and copy everything into it
          rm -rf $(pwd)/.nimbledeps
          mkdir -p $(pwd)/.nimbledeps
          cp -r ${deps}/* $(pwd)/.nimbledeps/

          # Nimble likes to write to files in it
          chmod -R +w .nimbledeps

          # Make sure nimble.paths points to our deps
          nimble -l setup --offline
        '';
        buildPhase = ''
          runHook preBuild

          ${setupNimbleDir}

          nimble --useSystemNim --nim:${pkgs.nim}/bin/nim --nimcache:$(mktemp -d) --offline -d:release build

          runHook postBuild
        '';

        doCheck = true;
        checkPhase = ''
          runHook preCheck

          nimble --useSystemNim --nim:${pkgs.nim}/bin/nim --offline test

          runHook postCheck
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin/
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
    );
}
