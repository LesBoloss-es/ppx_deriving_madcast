{ ... }: {
  perSystem = { self', ... }: {
    packages.default = self'.packages.ppx_deriving_madcast;
  };
}
