<h1 align="center">Ayugram desktop 🌐 NixOS flake</h1>

<div align="center">

![GitHub repo size](https://img.shields.io/github/repo-size/ayugram-port/ayugram-desktop?style=for-the-badge&cacheSeconds=180)

![GitHub License](https://img.shields.io/github/license/ayugram-port/ayugram-desktop?style=for-the-badge)
</div>

> [!TIP]
> NEW!!!
> `ayugram-desktop` is already in [nixpkgs](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/ay/ayugram-desktop/package.nix)
> it's override for `telegram-desktop`, so `ndfined-crp/ayugram-desktop`
> flake is still better

> [!NOTE]
> We do have binary cache via [Garnix CI](https://garnix.io/).
> In case you'll setup it manually - make sure to rebuild with
> activated cache **BEFORE** adding `ayugram` your packages.

<h2 align="center">☄️ Installation Instructions</h2>

1. You'll need to add this repo into your `flake.nix`:

   ```nix
   {
     inputs = {
       nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
       ayugram-desktop = {
         type = "git";
         submodules = true;
         url = "https://github.com/ndfined-crp/ayugram-desktop/";
        };
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

   ```nix
   # Nixos configuraion
   {
     pkgs,
     inputs,
     ...
   }: {
     environment.systemPackages = with pkgs; [
       inputs.ayugram-desktop.packages.${pkgs.system}.ayugram-desktop
     ];
   }
   ```

   ```nix
   # Home-manager configuration
   {
     pkgs,
     inputs,
     ...
   }: {
     home.packages = with pkgs; [
       inputs.ayugram-desktop.packages.${pkgs.system}.ayugram-desktop
     ];
   }
   ```

3. Now rebuild, and feel free to use `ayugram-desktop`!

<h2 align="center"> ⚡ Manual Binary Cache Setup</h2>

Simpy add it into your `nix` settings inside nixos configuration:

```nix
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

<h2 align="center"> 🪐 P.S.:</h2>

| Thanks                                            | to                                                                          |
| ------------------------------------------------- | --------------------------------------------------------------------------- |
| 🪐 [shwewo](https://github.com/shwewo)            | for original [repo](https://github.com/shwewo/ayugram-desktop).             |
| 🪐 [kaeeraa](https://github.com/kaeeraa)          | for fork adoption.                                                          |
| 🪐 [AyuGram](https://github.com/AyuGram)          | for the [ayugram-dektop](https://github.com/AyuGram/AyuGramDesktop) itself. |
| 🪐 [hand7s](https://github.com/s0me1newithhands7) | for this awesome readme (:D) and some work with package format.             |
