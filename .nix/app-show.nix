{ ... }: {
  perSystem = { self', ... }: {
    apps.show = {
      type = "app";
      program =
        "${self'.packages.ppx_deriving_madcast}/bin/ppx_deriving_madcast_show";
    };
  };
}
