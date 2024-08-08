#  Ayugram desktop 🌐 NixOS flake 

[![Cachix](https://github.com/kaeeraa/ayugram-desktop/actions/workflows/cachix.yml/badge.svg)](https://github.com/kaeeraa/ayugram-desktop/actions/workflows/cachix.yml)
[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/kaeeraa/ayugram-desktop/badge)](https://flakehub.com/flake/kaeeraa/ayugram-desktop)


## ☄️ Installation Instructions

### FlakeHub


```nix
# flake.nix
{
  inputs.ayugram-desktop.url = "https://flakehub.com/f/kaeeraa/ayugram-desktop/*.tar.gz";

  outputs = { self, ayugram-desktop }: {
    # Use in your outputs
  };
}

```

```nix
# configuration.nix
environment.systemPackages = with pkgs; [
  inputs.ayugram-desktop.packages.${pkgs.system}.default
];

```

### From a repository

```nix
# flake.nix
{
  inputs.ayugram-desktop.url = "git+https://github.com/kaeeraa/ayugram-desktop?submodules=1"; # add this
  
  outputs = { self, ayugram-desktop, ... }: { # also add @ inputs
    # Use in your outputs
  };
}

```

```nix
# configuration.nix
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