# ayugram-desktop

**🌐 English** · [Русский](README.ru.md)

> AyuGram for Nix — the first-class way to run [AyuGram], a feature-rich
> Telegram Desktop fork, on NixOS and other Linux distributions.

[AyuGram]: https://github.com/AyuGram/AyuGramDesktop

[![Flake](https://img.shields.io/badge/nix-flake-blueviolet?logo=nixos&logoColor=white&style=flat-square)](https://nixos.wiki/wiki/Flakes)
[![Platforms](https://img.shields.io/badge/Linux-x86__64%20%7C%20aarch64-informational?logo=linux&logoColor=white&style=flat-square)]()
[![License](https://img.shields.io/badge/license-GPL--3-blue?logo=opensourceinitiative&logoColor=white&style=flat-square)](https://www.gnu.org/licenses/gpl-3.0)
[![Cachix](https://img.shields.io/badge/cachix-ayugram--desktop-7c77f8?style=flat-square)](https://app.cachix.org/cache/ayugram-desktop)

---

## What makes it different

The `nixpkgs` package of AyuGram is an *override* of `telegram-desktop`. This
flake builds AyuGram **from its own source tree**, ahead of release, so the
build is always verified by CI and never inherits breakage from the base
client.

Prebuilt binaries are served from two binary caches, enabled automatically
when this flake is used:

| Cache | Contents |
| --- | --- |
| `ayugram-desktop.cachix.org` | the application |
| `tg-owt.cachix.org` | `tg_owt`, the WebRTC dependency |

## Requirements

| Requirement | Notes |
| --- | --- |
| Nix with [flakes] enabled | `nixos-unstable` works out of the box |
| Linux · `x86_64` or `aarch64` | other platforms are not covered by CI |

[flakes]: https://nixos.org/wiki/Flakes

## Quick start

Give it a spin without installing anything:

```console
nix run github:ndfined-crp/ayugram-desktop
```

It will open AyuGram right away. From here you can either use it as is, or
add it to your system.

## Using it in a configuration

Add the input to your flake and let its `nixpkgs` follow yours, so both roots
share the same revision:

```nix
{
  inputs = {
    ayugram-desktop = {
      url = "github:ndfined-crp/ayugram-desktop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
}
```

Install it system-wide (NixOS):

```nix
{ pkgs, inputs, ... }: {
  environment.systemPackages = [
    inputs.ayugram-desktop.packages.${pkgs.system}.default
  ];
}
```

Or per user (Home Manager):

```nix
{ pkgs, inputs, ... }: {
  home.packages = [
    inputs.ayugram-desktop.packages.${pkgs.system}.default
  ];
}
```

> After `nixos-rebuild switch` or `home-manager switch`, launch **AyuGram**.

## Binary caches, manual setup

The caches listed above are normally picked up from the flake's `nixConfig`.
If your Nix daemon ignores them, set them up yourself:

```nix
nix = {
  settings = {
    substituters = ["https://ayugram-desktop.cachix.org"];
    trusted-public-keys = [
      "ayugram-desktop.cachix.org-1:AZ5EqHrJsAKL5YkZYLPEsb1FdD9QlypUwQ0REcJftgA="
    ];
  };
  extra-substituters = ["https://tg-owt.cachix.org"];
  extra-trusted-public-keys = [
    "tg-owt.cachix.org-1:lp0BukIhSK3EIyLcDhDZ5zABgT48nmNp6t4SnZ0wr8w="
  ];
};
```

## FAQ

**Does this redefine `telegram-desktop`?**
No — AyuGram is built from its own tree. That also means a broken `tdesktop`
update never affects it.

**Which platforms are supported?**
`x86_64-linux` and `aarch64-linux`. Other platforms lack CI and a test device.

**What about crash reports?**
Untouched. They go wherever AyuGram normally sends them; nothing is redirected.

## Maintainers

The flake is maintained by **[hand7s](https://github.com/s0me1newithand7s)** and
**[fractal](https://github.com/fractal-l)**. Contributions and build reports
are welcome.

## License

The flake itself is licensed under [GPL-3.0-or-later](./LICENSE), matching
AyuGram. AyuGramDesktop is distributed under the same terms by
[its authors](https://github.com/AyuGram/AyuGramDesktop).