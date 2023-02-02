{
  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    nixpkgs.follows = "opam-nix/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.pre-commit-hooks.flakeModule
        ./.nix/app-show.nix
        ./.nix/devshell-default.nix
        ./.nix/formatter.nix
        ./.nix/package-ppx_deriving_madcast.nix
        ./.nix/package-default.nix
        ./.nix/perinput-lib.nix
        ./.nix/pre-commit-settings.nix
        ./.nix/pre-commit-settings-dune-opam-sync.nix
        ./.nix/pre-commit-settings-ocp-indent.nix
        ./.nix/pre-commit-settings-opam-lint.nix
        ./.nix/systems.nix
      ];
    };
}
