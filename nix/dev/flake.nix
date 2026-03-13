{
  description = "Git extras and dev utilities";

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
            name = "dev-tools";
            paths = with pkgs; [
              # Git extras
              git
              tig
              git-absorb
              difftastic
              gitleaks
              git-cliff

              # Dev utilities
              tokei
              hyperfine
              just
              watchexec
              tldr
              nix-tree
            ];
          };
        }
      );
    };
}
