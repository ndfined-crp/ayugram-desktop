{
  description = "AyuGram Desktop";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
  };
  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems (system: f {
        inherit system;
        pkgs = import nixpkgs {inherit system;};
      });
    in
    {
      overlays.default = final: _prev: {
        ayugram-desktop = self.packages.${final.system}.default;
      };

      packages = forEachSystem ({pkgs, ...}: {
        default = pkgs.libsForQt5.callPackage ./default.nix {};
        ayugram-desktop = self.packages.${pkgs.system}.default;
      });
    };
}
