{
  description = "AyuGram Desktop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  nixConfig = {
    extra-substituters = ["https://cache.garnix.io"];
    extra-trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="];
  };
  outputs = {
    self,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
      flake = {
        overlays.default = final: prev: {
          ayugram-desktop = final.kdePackages.callPackage ./default.nix {};
        };
      };
      perSystem = {pkgs, ...}: {
        packages = {
          default = pkgs.ayugram-desktop;
          ayugram-desktop = self.ayugram-desktop;
        };
      };
    };
}
