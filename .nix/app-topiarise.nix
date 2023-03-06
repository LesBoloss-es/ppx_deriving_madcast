{ ... }: {
  perSystem = { inputs', pkgs, ... }: {
    apps.topiarise = {
      type = "app";
      program = pkgs.writeShellApplication {
        name = "topiarise";
        text = ''
          find . '(' -name '*.ml' -o -name '*.mli' ')' -print -exec \
            ${inputs'.topiary.packages.default}/bin/topiary --in-place --input-file '{}' ';'
        '';
      };
    };
  };
}
