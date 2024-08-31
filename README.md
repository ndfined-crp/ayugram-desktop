#  Ayugram desktop 🌐 NixOS flake 

## ⚠️ This is the “master” branch, proceed to release branch if you need more stability

[![Cachix](https://github.com/kaeeraa/ayugram-desktop/actions/workflows/cachix.yml/badge.svg)](https://github.com/kaeeraa/ayugram-desktop/actions/workflows/cachix.yml)
[![wakatime](https://wakatime.com/badge/github/kaeeraa/ayugram-desktop.svg)](https://wakatime.com/badge/github/kaeeraa/ayugram-desktop)

## ☄️ Installation Instructions

### With nix profile (the easiest way to install)

Use the following command:

```shell
$ nix profile install github+kaeeraa/ayugram-desktop/master 
```

Answer at all questions `y`

### From a repository

```nix
# flake.nix
{
  inputs.ayugram-desktop.url = "github:kaeeraa/ayugram-desktop/master?submodules=1";
  
  outputs = { self, ayugram-desktop, ... }: {
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

### You can also use the binary cache if you want to skip building.

#### Auto using cache

Cache already built in this flake, you just need to trust it.

#### Manual using cache

Set it directly in the configuration:

```nix
# configuration.nix
nix = {
  settings = {
    substituters = [
      "https://cache.garnix.io"
    ];
    trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
    # other options...
  };
};
```

Then after that make rebuild **WITHOUT** `inputs.ayugram-desktop.packages.${pkgs.system}.default` in your packages.

Now cache is ready to be used.

## 🪐 Thanks to shwewo

### Forked from [shwewo/ayugram-desktop](https://github.com/shwewo/ayugram-desktop) for [AyuGram/AyuGramDesktop](https://github.com/telegramdesktop/tdesktop)