# Returns the output of `nimble dump` in a structured format
{ pkgs }:
{ src }:
builtins.fromJSON (
  builtins.readFile (
    pkgs.stdenv.mkDerivation {
      name = "metadata";
      nativeBuildInputs = with pkgs; [
        nimble
        nim
        jq
      ];
      src = src;
      installPhase = ''
        export NIMBLE_DIR=$(mktemp -d)
        export HOME=$(mktemp -d)
        set +e
        echo "=== Try 1: with --useSystemNim --offline ==="
        nimble --noLockfile --useSystemNim --offline dump --json 2>&1
        echo "exit: $?"
        echo ""
        echo "=== Try 2: without --useSystemNim ==="
        nimble --noLockfile --offline dump --json 2>&1
        echo "exit: $?"
        echo ""
        echo "=== Try 3: minimal ==="
        nimble dump --json 2>&1
        echo "exit: $?"
        echo ""
        echo "=== Try 4: --localdeps ==="
        nimble -l dump --json 2>&1
        echo "exit: $?"
        exit 1
      '';
    }
  )
)
