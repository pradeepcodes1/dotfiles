{
  description = "Pradeep default CLI tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = pkgs.buildEnv {
      name = "pradeep-cli";
      paths = with pkgs; [
        # core
        git git-lfs gh neovim tmux zsh chezmoi gh lazygit

        # navigation / UX
        ripgrep fd fzf bat btop tree zoxide yazi

        # infra
        docker docker-compose colima kind
        rclone restic scrcpy

        # network / security
        httpie jq openssl gnupg pass unbound

        mise zsh-syntax-highlighting zsh-autosuggestions

        pinentry-curses
      ];
    };
  };
}

