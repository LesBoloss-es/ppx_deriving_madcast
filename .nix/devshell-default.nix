{ ... }: {
  perSystem = { self', pkgs, config, ... }: {
    devShells.default = pkgs.mkShell {
      buildInputs = with self'.packages.ppx_deriving_madcast.scope; [
        merlin
        ocaml-lsp-server
        ocp-indent
        odoc
        opam-publish
        utop
      ];
      inputsFrom = [ self'.packages.ppx_deriving_madcast ];
      shellHook = config.pre-commit.installationScript;
    };
  };
}
