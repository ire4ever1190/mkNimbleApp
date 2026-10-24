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
        nim
      ];
      src = src;
      installPhase = ''
        # Macro can't be used to include the file dynamically, so replace it in the source
        echo sed s/@NIMBLE_FILE/$(find -name *.nimble)/
        sed s!@NIMBLE_FILE!$(find -name *.nimble)! ${./infoDumper.nim} > infoDumper.nim

        nim r --nimcache:$(mktemp -d) infoDumper.nim > $out
      '';
    }
  )
)
