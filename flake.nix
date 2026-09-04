{
  description = "generic flake.nix project base";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    systems.url = "github:nix-systems/default";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";
    git-hooks-nix.inputs.flake-compat.follows = "flake-compat";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks-nix.flakeModule
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          system,
          ...
        }:
        let
          overlays = [ ];
          pkgs = import inputs.nixpkgs { inherit system overlays; };
          pkgs-stable = import inputs.nixpkgs-stable { inherit system overlays; };
          repoRoot = ./.;
          lib = pkgs.lib;
        in
        {
          pre-commit = {
            settings = {
              enable = true;
              install.enable = true;
              hooks.treefmt.enable = true;
            };
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs.mdformat.enable = true;
            programs.nixfmt.enable = true;
            programs.nixfmt.package = pkgs.nixfmt;
            programs.shfmt.enable = true;
          };

          devShells.default = pkgs.mkShell {
            buildInputs = (
              with pkgs;
              [
                bashInteractive
                cljfmt
                config.treefmt.build.wrapper
                direnv
                fd
                gnugrep
                gnused
                jq
                nixfmt
                openssl
                openssl.dev
                pkg-config
                pre-commit
                ripgrep
                shellcheck
                shfmt
              ]
            );
            shellHook = ''
              export PATH="$PWD/bin:$PATH"
              export SHELL="${pkgs.bashInteractive}/bin/bash"
              export EDITOR="rly"
              export VISUAL="rly"
              ${config.pre-commit.settings.installationScript}
            '';
          };
        };
    };
}
