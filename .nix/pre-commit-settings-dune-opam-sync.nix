{ ... }: {
  perSystem = { pkgs, ... }: {
    pre-commit.settings.hooks.dune-opam-sync = {
      enable = true;
      name = "dune/opam sync";
      entry = let
        dune-build-opam-file = pkgs.writeShellApplication {
          name = "dune-build-opam-file";
          runtimeInputs = [ pkgs.pkgsBuildBuild.ocaml ];
          text = ''
            set -e
            find . -type f -name '*.opam' | while read -r file; do
                ${pkgs.dune_3}/bin/dune build "$file"
            done
          '';
        };
      in "${dune-build-opam-file}/bin/dune-build-opam-file";
      files = "(\\.opam$)|((^|/)dune-project$)";
      pass_filenames = false;
    };
  };
}
