{
    description = "AyuGram Desktop";

    inputs = {
        nixpkgs = {
            url = "github:nixos/nixpkgs/nixos-unstable";
        };

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = {
        self,
        nixpkgs,
        home-manager,
        ...
    } @ inputs :

    let
        forAllSystems = function:
            nixpkgs.lib.genAttrs [
                "x86_64-linux"
                "aarch64-linux"
                "x86_64-darwin"
                "aarch64-darwin"
            ] (
                system: function nixpkgs.legacyPackages.${system}
            );
    in {
        overlays = {
            ayugram-desktop = final: prev: self.packages;
        };

        packages = forAllSystems ( pkgs: {
            ayugram-desktop = pkgs.libsForQt5.callPackage ./default.nix {};
        });
    };

    nixConfig = {
        extra-substituters = [ 
            "https://cache.garnix.io"
        ];

        extra-trusted-public-keys = [ 
            "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];
    };
}
