{ ... }: {
  perSystem = { inputs', pkgs, ... }: {
    pre-commit.settings.hooks.topiary = {
      enable = true;
      name = "topiary";
      entry = let
        topiary-inplace = pkgs.writeShellApplication {
          name = "topiary-inplace";
          text = ''
            printf 'Running Topiary in place on `%s´...\n' "$1"
            ${inputs'.topiary.packages.default}/bin/topiary -i "$1" -o "$1".tmp && true
            mv "$1".tmp "$1"
          '';
        };
      in "${topiary-inplace}/bin/topiary-inplace";
      files = "\\.mli?$";
    };
  };
}
