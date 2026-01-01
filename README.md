# mkNimbleApp

Nix flake utility for wrapping nimble binary projects. Can get most of the information needed from your nimble
files and produce a derivation containing all the binaries

## Usage

Add this into your flake inputs
```nix
nimbleUtils = {
  url = "github:ire4ever1190/mkNimbleApp";
  inputs.nixpkgs.follows = "nixpkgs";
}
```
and then call it inside your flake
```nix
let
  mkNimbleApp = nimbleUtils.packages.${system}.default;
in
  mkNimbleApp {
    src = ./.;
  
    # The first run WILL fail, just paste the given hash in after aftwards
    nimbleHash = ""; 
  
    meta = {
      description = "Some nimble app";
      homepage = "https://github.com/foo/bar";
      license = pkgs.lib.licenses.mit;
      mainProgram = "someBinary";
    };
  }
```
