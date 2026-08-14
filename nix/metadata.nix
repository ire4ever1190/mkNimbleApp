# Returns the output of `nimble dump` in a structured format
{ pkgs }:
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
)
