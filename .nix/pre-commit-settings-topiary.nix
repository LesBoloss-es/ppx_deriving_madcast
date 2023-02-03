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
            ${inputs'.topiary.packages.default}/bin/topiary -i "$1" \
                | ${pkgs.moreutils}/bin/sponge "$1"
          '';
        };
      in "${topiary-inplace}/bin/topiary-inplace";
      files = "\\.mli?$";
    };
  };
}
