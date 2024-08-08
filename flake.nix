{
  description = "Desktop Telegram client with good customization and Ghost mode.";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages = rec {
          ayugram-desktop = (pkgs.libsForQt5.callPackage ./default.nix {});
          default = ayugram-desktop;
        };
      }
    );
}