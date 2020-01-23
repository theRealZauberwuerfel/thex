{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc865", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, base, c2hs, containers, ncurses, stdenv, text
      , transformers
      }:
      mkDerivation {
        pname = "ncurses";
        version = "0.2.16";
        src = ./.;
        revision = "1";
        editedCabalFile = "1wfdy716s5p1sqp2gsg43x8wch2dxg0vmbbndlb2h3d8c9jzxnca";
        libraryHaskellDepends = [ base containers text transformers ];
        librarySystemDepends = [ ncurses ];
        libraryToolDepends = [ c2hs ];
        homepage = "https://john-millikin.com/software/haskell-ncurses/";
        description = "Modernised bindings to GNU ncurses";
        license = stdenv.lib.licenses.gpl3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
