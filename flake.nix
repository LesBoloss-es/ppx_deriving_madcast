{
  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    nixpkgs.follows = "opam-nix/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    topiary.url = "github:tweag/topiary?ref=niols/pre-commit-hook.nix";
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
        ./.nix/pre-commit-settings-opam-lint.nix
        ./.nix/systems.nix
      ];
    };

  nixConfig = {
    extra-trusted-substituters = [ "https://ppx-deriving-madcast.cachix.org/" ];
    extra-trusted-public-keys = [
      "ppx-deriving-madcast.cachix.org-1:nWv3lv2Md9LX0M1CtT7TGWS2HwGdb6N9xuAHbbk8h/g="
    ];
  };
}
