{
  description = "A flake for building SOSlib for Flint";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;

  inputs.flint-libsbml = {
    url = github:flintproject/flint-libsbml/f4a93d6a98d4709e57679942d738ef6c5b91b25d;
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
