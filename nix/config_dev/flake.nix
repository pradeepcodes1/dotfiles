{
  description = "Pradeep config dev tools";

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
            name = "pradeep-config-dev";
            paths = with pkgs; [
              # Chezmoi and secrets
              chezmoi
              age

              # Editor and development tools
              neovim
              git

              # Shell utilities
              fzf
              ripgrep
              jq

              # Diff and merge tools
              diffutils
            ];
          };
        }
      );
    };
}