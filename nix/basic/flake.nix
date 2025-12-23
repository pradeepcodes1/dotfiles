{
  description = "Pradeep basic CLI tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
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
            name = "pradeep-basic-cli";
            paths = with pkgs; [
              # core
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
              bat
              btop
              tree
              zoxide
              yazi

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
            ];
          };
        }
      );
    };
}
