{
  description = "Bootstrap tools for chezmoi setup";

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
            name = "chezmoi-bootstrap";
            paths = with pkgs; [
              # Chezmoi itself
              chezmoi

              # Required for chezmoi templates using pass
              pass
              gnupg
              pinentry-curses

              # Basic tools
              git
              curl
              zsh
            ];
          };
        }
      );
    };
}
