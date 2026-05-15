{
  description = "AyuGram Desktop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    tg_owt = {
      url = "github:ndfined-crp/tg_owt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
      "https://ayugram-desktop.cachix.org"
      "https://tg-owt.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "ayugram-desktop.cachix.org-1:AZ5EqHrJsAKL5YkZYLPEsb1FdD9QlypUwQ0REcJftgA="
      "tg-owt.cachix.org-1:lp0BukIhSK3EIyLcDhDZ5zABgT48nmNp6t4SnZ0wr8w="
    ];
  };
  outputs = inputs: let
    inherit (inputs) nixpkgs tg_owt;

    systems = ["x86_64-linux" "aarch64-linux"];
    forEachSystem = nixpkgs.lib.genAttrs systems;
  in {
    packages = forEachSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      ayugram-desktop = pkgs.kdePackages.callPackage ./default.nix {tg_owt = tg_owt.packages.${system}.default;};
    in {
      inherit ayugram-desktop;
      default = ayugram-desktop;
    });
  };
}
