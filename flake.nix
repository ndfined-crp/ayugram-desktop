{
  description = "AyuGram Desktop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  nixConfig = {
    extra-substituters = ["https://cache.garnix.io" "https://ayugram-desktop.cachix.org"];
    extra-trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" "ayugram-desktop.cachix.org-1:AZ5EqHrJsAKL5YkZYLPEsb1FdD9QlypUwQ0REcJftgA="];
  };
  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [flake-parts.flakeModules.easyOverlay inputs.git-hooks.flakeModule];
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {
        config,
        pkgs,
        ...
      }: let
        AyuGram = pkgs.kdePackages.callPackage ./default.nix {};
      in {
        overlayAttrs = {inherit (config.packages) default;};
        packages = {
          default = AyuGram;
          ayugram-desktop = AyuGram;
        };
        pre-commit.settings.hooks = {
          alejandra.enable = true;
          statix.enable = true;
          deadnix.enable = true;
        };
      };
    };
}
