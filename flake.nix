{
  description = "A Catppuccin desktop shell for Hyprland, built with Quickshell";

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
          worktreeSafeSource = builtins.path {
            path = ./.;
            name = "hyprshell-source";
            filter = path: _type: baseNameOf path != ".git";
          };
          hyprshell = pkgs.writeShellApplication {
            name = "hyprshell";
            runtimeInputs = with pkgs; [
              bash
              coreutils
              gawk
              quickshell
            ];
            text = ''
              export QT_QPA_PLATFORM=wayland
              exec quickshell --path ${./quickshell} "$@"
            '';
          };
        in
        {
          apps.default = {
            type = "app";
            program = "${hyprshell}/bin/hyprshell";
            meta.description = "Launch the Hyprshell Quickshell configuration";
          };

          packages = {
            hyprshell = hyprshell;
            default = hyprshell;
          };

          pre-commit = {
            settings = {
              enable = true;
              # Linked worktrees contain a .git pointer whose target is not
              # available in Nix build sandboxes. Let the check initialize its
              # own repository instead.
              rootSrc = pkgs.lib.mkForce worktreeSafeSource;
              install.enable = true;
              hooks.treefmt.enable = true;
            };
          };

          treefmt = {
            projectRoot = pkgs.lib.mkForce worktreeSafeSource;
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
                quickshell
                ripgrep
                shellcheck
                shfmt
                qt6.qtdeclarative
                libnotify
              ]
            );
            shellHook = ''
              export PATH="$PWD/bin:$PATH"
              export SHELL="${pkgs.bashInteractive}/bin/bash"
              export EDITOR="rly"
              export VISUAL="rly"
              export QT_QPA_PLATFORM="wayland"
              ${config.pre-commit.settings.installationScript}
            '';
          };
        };
    };
}
