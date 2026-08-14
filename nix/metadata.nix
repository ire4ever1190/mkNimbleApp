# Returns the output of `nimble dump` in a structured format
{ pkgs }:
{ src }:
builtins.fromJSON (
  builtins.readFile (
    pkgs.stdenv.mkDerivation {
      name = "metadata";
      nativeBuildInputs = with pkgs; [
        (pkgs.callPackage ./pkgs/nimble.nix { })
        jq
      ];
      src = src;
      installPhase = ''
        # We need to delete nimDir since it refers to a store path
        nimble -l --offline dump --json --silent | jq 'del(.nimDir)' > $out
      '';
    }
  )
)
