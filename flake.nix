{
  description = "fdflib - FDF Core UI Component Library";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = {
          fdflib = pkgs.stdenv.mkDerivation {
            name = "fdflib";
            src = ./.;

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              mkdir -p $out/FDF
              cp -r ./*.qml $out/FDF/
              cp ./qmldir $out/FDF/
            '';
          };
          default = self.packages.${system}.fdflib;
        };
      });
}
