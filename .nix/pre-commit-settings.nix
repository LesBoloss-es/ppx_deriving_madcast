{ ... }: {
  perSystem = { inputs', ... }: {
    pre-commit.settings.hooks = {
      nixfmt.enable = true;
      deadnix.enable = true;
      topiary = inputs'.topiary.lib.pre-commit-hook;
      dune-opam-sync.enable = true;
      opam-lint.enable = true;
    };
  };
}
