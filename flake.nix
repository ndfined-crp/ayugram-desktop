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
    }@inputs:
    let
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ] (system: function nixpkgs.legacyPackages.${system});
    in
    {
      overlays.ayugaram-desktop = (
        final: _prev: {
          ayugram-desktop = self.packages;
        }
      );

      nixosModules = {
        ayugram-desktop = self.overlays;
        default = self.overlays;
      };

      homeManagerModules = {
        ayugram-desktop = self.overlays;
        default = self.overlays;
      };

      packages = forAllSystems (pkgs: {
        ayugram-desktop = pkgs.libsForQt5.callPackage ./default.nix { };
      });
    };
}
