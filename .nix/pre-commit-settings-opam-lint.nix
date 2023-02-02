{ ... }: {
  perSystem = { pkgs, ... }: {
    pre-commit.settings.hooks.opam-lint = {
      enable = true;
      name = "opam lint";
      entry = "${pkgs.opam}/bin/opam lint";
      files = "\\.opam$";
    };
  };
}
