{
  description = "Pradeep default CLI tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      packages = forAllSystems (
        { pkgs, system }:
        {
          default = pkgs.buildEnv {
            name = "pradeep-cli";
            paths = with pkgs; [
              # core (chezmoi installed separately, not here)
              wget
              git
              git-lfs
              gh
              neovim
              tmux
              zsh
              lazygit

              # navigation / UX
              ripgrep
              fd
              fzf
              atuin
              bat
              delta
              btop
              tree
              zoxide
              yazi
              eza

              # infra
              docker
              colima
              docker-compose

              # network / security
              httpie
              jq
              openssl

              # shell tooling
              mise
              zsh-syntax-highlighting
              zsh-autosuggestions
              zsh-fzf-tab
              carapace

              # utilities
              glow
              htop
              lnav
              restic
              unbound
              iina
            ];
          };
        }
      );
    };
}
