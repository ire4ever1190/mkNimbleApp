{ pkgs }:
let

in
{
  # buildAtlasApp = pkgs.stdenv.lib.extendMkDerivation {
  #   constructDrv = pkgs.stdenv.mkDerivation;
  #   excludeDrvArgNames = [
  #     "atlasHash"
  #   ];
  # }: {
  #   nativeBuildInputs = args.nativeBuildInputs // (with pkgs; [nim])
  # };
  # TODO: Use this to build atlas

}
