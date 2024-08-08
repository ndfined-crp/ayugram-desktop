# 🌐 Ayugram desktop | NixOS flake 🌐

## ☄️ Installation Instructions

Example `flake.nix` (don't copy it fully):

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    
    ayugram-desktop.url = "git+https://github.com/kaeeraa/ayugram-desktop?submodules=1"; # add this
  };

  outputs = { self, nixpkgs, ... }@ inputs: { # also add @ inputs
    nixosConfigurations.kaeeraa-dev = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; # and this line
      modules = [ ./configuration.nix ];
    };
  };
}

```

To use it in your system add this to your configuration.nix: 

```nix
environment.systemPackages = with pkgs; [
  inputs.ayugram-desktop.packages.${pkgs.system}.default
];
```

## ⚡ Binary cache

### You can also use the binary cache, if you want to skip building.

#### Auto using cache

Cache already built in this flake, you just need to trust it.

#### Manual using cache

First way to use the binary cache is use the cachix command:

```shell
$ cachix use kaeeraa
```

Second way to use the binary cache is set it directly in the configuration:

```nix
nix = {
  settings = {
    substituters = [
      "https://kaeeraa.cachix.org"
    ];
    trusted-public-keys = [
      "kaeeraa.cachix.org-1:S3CnhT12akYQf4Ph7fndLgqo2os4ket3OTP2amrzJRs="
    ];
    # other options...
  };
};
```

## 🪐 Thanks to shwewo