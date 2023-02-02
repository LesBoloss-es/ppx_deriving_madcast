{ ... }: {
  perSystem = { inputs', pkgs, ... }:
    ## NOTE: The use of `../.` matters because the path is taken as relative to
    ## the current file, and therefore to `/.nix`.
    let
      scope = inputs'.opam-nix.lib.buildOpamProject { inherit pkgs; }
        "ppx_deriving_madcast" ../. {
          merlin = "*";
          ocaml-base-compiler = "*";
          ocaml-lsp-server = "*";
          opam-publish = "*";
          odoc = "*";
          ocp-indent = "*";
          utop = "*";
        };
    in {
      packages.ppx_deriving_madcast = scope.ppx_deriving_madcast // {
        inherit scope;
      };
    };
}
