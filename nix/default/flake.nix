{
  description = "Pradeep default CLI tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    systems = [
      "aarch64-darwin"
      "aarch64-linux"
    ];

    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system:
        f {
          inherit system;
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );
  in {
    packages = forAllSystems ({ pkgs, system }: {
      default = pkgs.buildEnv {
        name = "pradeep-cli";
        paths = with pkgs; [
          # core
          git git-lfs gh neovim tmux zsh chezmoi lazygit

          # navigation / UX
          ripgrep fd fzf bat btop tree zoxide yazi

          # infra
          docker docker-compose kind
          rclone restic scrcpy

          # network / security
          httpie jq openssl gnupg pass unbound

          # shell tooling
          mise zsh-syntax-highlighting zsh-autosuggestions

          pinentry-curses
        ];
      };
    });
  };
}
