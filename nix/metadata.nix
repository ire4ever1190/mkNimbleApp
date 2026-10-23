# Returns the output of `nimble dump` in a structured format
{ pkgs }:
{ src, deps }:
builtins.fromJSON (
  builtins.readFile (
    pkgs.stdenv.mkDerivation {
      name = "metadata";
      nativeBuildInputs = with pkgs; [
        nimble
        jq
        nim
      ];
      src = src;
      installPhase = ''
        # Copy of setupNimbleDir since it was easier than passing it through.
        # Deps need to be configured or else the dump fails and never tells you
        export NIMBLE_DIR=$(mktemp -d)
        ln -s ${deps}/pkgs2 $NIMBLE_DIR/pkgs2
        cp ${deps}/*.json $NIMBLE_DIR/
        chmod +w $NIMBLE_DIR/nimbledata2.json
        echo "[]" > $NIMBLE_DIR/packages_official.json
        echo "[]" > $NIMBLE_DIR/official-nim-releases.json

        # We need to delete nimDir since it refers to a store path
        nimble -l --useSystemNim --offline dump --json --silent | jq 'del(.nimDir)' > $out
      '';
    }
  )
)
