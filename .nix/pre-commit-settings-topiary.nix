{ ... }: {
  perSystem = { inputs', pkgs, ... }: {
    pre-commit.settings.hooks.topiary = {
      enable = true;
      name = "topiary";
      entry = let
        topiary-inplace = pkgs.writeShellApplication {
          name = "topiary-inplace";
          text = ''
            for file; do
              ${inputs'.topiary.packages.default}/bin/topiary -i "$file" \
                | ${pkgs.moreutils}/bin/sponge "$file"
            done
          '';
        };
      in "${topiary-inplace}/bin/topiary-inplace";
      files = "\\.mli?$";
    };
  };
}
