{ ... }: {
  perSystem = { pkgs, ... }: {
    pre-commit.settings.hooks.ocp-indent = {
      enable = true;
      name = "ocp-indent";
      entry = "${pkgs.ocamlPackages.ocp-indent}/bin/ocp-indent --inplace";
      files = "(\\.ml$)|(\\.mli$)";
    };
  };
}
