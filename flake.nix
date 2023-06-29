{
  description = "A flake for building SOSlib for Flint";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;

  inputs.flint-libsbml = {
    url = github:flintproject/flint-libsbml/30766407c7d6f692d94f77a6e1cdd7a4a7d02f84;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.flint-sundials = {
    url = github:flintproject/flint-sundials;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.soslib = {
    url = github:raim/SBML_odeSolver;
    flake = false;
  };

  outputs = { self, nixpkgs, flint-libsbml, flint-sundials, soslib }: let

    allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f (import nixpkgs { inherit system; }));

  in {

    packages = forAllSystems (pkgs: with pkgs; let

      flint-soslib = stdenv.mkDerivation {
        pname = "flint-soslib";
        version = "1.9.0.0";

        nativeBuildInputs = [ autoreconfHook pkg-config ];

        buildInputs = [ pkg-config libxml2 flint-libsbml.packages.${system}.default flint-sundials.packages.${system}.default ];

        checkInputs = [ check ];

        src = soslib;

        patches = [ ./makefile-am.patch ];

        configureFlags = [
          # "--enable-unittest"
          "--with-libsbml=${flint-libsbml}"
          "--with-sundials=${flint-sundials}"
        ];

        # doCheck = true;

        enableParallelBuilding = true;
      };

    in {

      default = flint-soslib;

    });
  };
}
