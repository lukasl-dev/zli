{
  description = "zli";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    zig-overlay.follows = "zls/zig-overlay";
    zls.url = "github:zigtools/zls";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      zig-overlay,
      zls,
    }:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);

      mkZig = system: zig-overlay.packages.${system}.master;
    in
    {
      devShells = forEachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };

          zig = mkZig system;
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              zig
              zls.packages.${system}.zls
            ];
          };
        }
      );
    };
}
