# Ayugram desktop 🌐 NixOS flake {: .center}

![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/kaeeraa/ayugram-desktop?style=for-the-badge) ![GitHub License](https://img.shields.io/github/license/kaeeraa/ayugram-desktop?style=for-the-badge)

> [!NOTE]
> We do have binary cache via [Garnix](https://garnix.io/) CI. In case you'll setup it manually - make sure to rebuild with activated cache **BEFORE** adding `ayugram` into `environment.systemPackages` or `home.packages.`.

## ☄️ Installation Instructions {: .center}

  1. You'll need to add this repo into your `flake.nix`:

    ```Nix
    {
      inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        ayugram-desktop.url = "github:kaeeraa/ayugram-desktop/release?submodules=1";
      };

      outputs = {
        self,
        nixpkgs,
        ayugram-desktop,
        ...
      }: {
        ...
      };
    }
    ```

  2. After that, add package into your `environment.systemPackages` or `home.packages`:

    ```Nix
    # Nixos configuraion
    {
      pkgs,
      inputs,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        inputs.ayugram-desktop.packages.${pkgs.system}.default
      ];
    }
    ```

    ```Nix
    # Home-manager configuration
    {
      pkgs,
      inputs,
      ...
    }: {
      home.packages = with pkgs; [
        inputs.ayugram-desktop.packages.${pkgs.system}.default
      ];
    }
    ```

  3. Now rebuild, and feel free to use `ayugram-desktop`!

## ⚡ Manual Binary Cache Setup {: .center}

Simpy add it into your `nix` settings inside nixos configuration:

    ```Nix
    nix = {
      settings = {
        substituters = [
          "https://cache.garnix.io"
        ];
        trusted-public-keys = [
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];
      };
    };
    ```

## 🪐 P.S.: {: .center}

| Thanks | to |
| - | - |
| 🪐 [shwewo](https://github.com/shwewo)| for original [repo](https://github.com/shwewo/ayugram-desktop).|
| 🪐 [kaeeraa](https://github.com/kaeeraa)| for fork adoption.|
| 🪐 [AyuGram](https://github.com/AyuGram)| for the [ayugram-dektop](https://github.com/AyuGram/AyuGramDesktop) itself.|
| 🪐 [hand7s](https://github.com/s0me1newithhands7)| for this awesome readme (:D) and some work with package format.|
