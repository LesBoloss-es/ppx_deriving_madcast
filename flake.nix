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
            utop = "*";
          };
      in
        {
          packages = packages // {
            default = self.packages.${system}.ppx_deriving_madcast;
          };

          devShells.default = pkgs.mkShell {
            buildInputs = [
              packages.merlin
              packages.ocaml-lsp-server
              packages.ocp-indent
              packages.utop
            ];
            inputsFrom = [ packages.ppx_deriving_madcast ];
          };
        });
}
