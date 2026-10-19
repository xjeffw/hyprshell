{
  description = "A Catppuccin desktop shell for Hyprland and niri, built with Quickshell";

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
    # Quickshell fork adding AlphaModifier.opacity (alpha-modifier-v1), used
    # to fade notifications along with the blur behind them.
    quickshell-src.url = "github:xjeffw/quickshell/alpha-modifier";
    quickshell-src.flake = false;
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
          quickshell = pkgs.quickshell.overrideAttrs { src = inputs.quickshell-src; };
          worktreeSafeSource = builtins.path {
            path = ./.;
            name = "hyprshell-source";
            filter = path: _type: baseNameOf path != ".git";
          };
          hyprshell = pkgs.writeShellApplication {
            name = "hyprshell";
            runtimeInputs = [
              pkgs.bash
              pkgs.coreutils
              pkgs.gawk
              quickshell
            ];
            text = ''
              export QT_QPA_PLATFORM=wayland

              # Run another copy of the config, e.g. a checkout being edited.
              config_dir=''${HYPRSHELL_CONFIG_DIR:-${./quickshell}}

              if (( $# > 0 )) && [[ $1 == request ]]; then
                shift
                if (( $# == 1 )); then
                  read -r -a request_words <<< "$1"
                  set -- "''${request_words[@]}"
                fi

                if (( $# == 0 )); then
                  echo "usage: hyprshell request <playPause|selectNextPlayer|nextTrack|previousTrack|seekDelta [seconds]>" >&2
                  exit 2
                fi

                request=$1
                shift
                case "$request" in
                  playPause | selectNextPlayer | nextTrack | previousTrack)
                    if (( $# != 0 )); then
                      echo "hyprshell request: $request does not accept arguments" >&2
                      exit 2
                    fi
                    exec quickshell --path "$config_dir" ipc call mpris "$request"
                    ;;
                  seekDelta)
                    if (( $# != 1 )); then
                      echo "hyprshell request: seekDelta requires one numeric seconds argument" >&2
                      exit 2
                    fi
                    exec quickshell --path "$config_dir" ipc call mpris seekDelta "$1"
                    ;;
                  *)
                    echo "hyprshell request: unknown command: $request" >&2
                    exit 2
                    ;;
                esac
              fi

              exec quickshell --path "$config_dir" "$@"
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
                ripgrep
                shellcheck
                shfmt
                qt6.qtdeclarative
                libnotify
              ]
              ++ [ quickshell ]
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
