{ ... }: {
  perSystem = { self', ... }: { packages.default = self'.packages.dancelor; };
}
