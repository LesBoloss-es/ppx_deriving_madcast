{
  inputs = {
    opam-nix.url = github:tweag/opam-nix;
    nixpkgs.follows = "opam-nix/nixpkgs";

    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, opam-nix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:

      let pkgs = nixpkgs.legacyPackages.${system};
          on = opam-nix.lib.${system};

          packages = on.buildOpamProject { pkgs = pkgs; } "ppx_deriving_madcast" ./. {
            merlin = "*";
            ocaml-base-compiler = "*";
            ocaml-lsp-server = "*";
            ocp-indent = "*";
            odoc = "*";
            utop = "*";
          };
      in
        {
          packages = packages // {
            default = packages.ppx_deriving_madcast;
          };

          apps.show = {
            type = "app";
            program = "${packages.ppx_deriving_madcast}/bin/ppx_deriving_madcast_show";
          };

          devShells.default = pkgs.mkShell {
            buildInputs = with packages; [
              merlin
              ocaml-lsp-server
              ocp-indent
              odoc
              utop
            ];
            inputsFrom = [ packages.ppx_deriving_madcast ];
          };
        });
}
