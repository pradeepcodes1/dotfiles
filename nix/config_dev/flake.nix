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
            name = "pradeep-config-dev";
            paths = with pkgs; [
              chezmoi
              age
            ];
          };
        }
      );
    };
}