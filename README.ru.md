# ayugram-desktop

**[English](README.md) · 🌐 Русский**

> AyuGram для Nix — самый «родной» способ запустить [AyuGram], форк
> Telegram Desktop с кучей возможностей, на NixOS и других Linux-системах.

[AyuGram]: https://github.com/AyuGram/AyuGramDesktop

[![Flake](https://img.shields.io/badge/nix-flake-blueviolet?logo=nixos&logoColor=white&style=flat-square)](https://nixos.wiki/wiki/Flakes)
[![Platforms](https://img.shields.io/badge/Linux-x86__64%20%7C%20aarch64-informational?logo=linux&logoColor=white&style=flat-square)]()
[![License](https://img.shields.io/badge/license-GPL--3-blue?logo=opensourceinitiative&logoColor=white&style=flat-square)](https://www.gnu.org/licenses/gpl-3.0)
[![Cachix](https://img.shields.io/badge/cachix-ayugram--desktop-7c77f8?style=flat-square)](https://app.cachix.org/cache/ayugram-desktop)

---

## Чем отличается

Пакет AyuGram из `nixpkgs` — это *override* `telegram-desktop`. Этот флейк
собирает AyuGram **из его собственного дерева исходников**, до релиза, так
что сборка всегда проверяется CI и никогда не наследует поломки базового
клиента.

Готовые бинарники раздаются из двух бинарных кэшей, которые подключаются
автоматически:

| Кэш | Что лежит |
| --- | --- |
| `ayugram-desktop.cachix.org` | само приложение |
| `tg-owt.cachix.org` | `tg_owt`, зависимость для WebRTC |

## Требования

| Требование | Примечание |
| --- | --- |
| Nix с включёнными [flakes] | из коробки работает `nixos-unstable` |
| Linux · `x86_64` или `aarch64` | другие платформы CI не покрывает |

[flakes]: https://nixos.org/wiki/Flakes

## Быстрый старт

Попробовать без установки:

```console
nix run github:ndfined-crp/ayugram-desktop
```

Сразу откроется AyuGram. После этого его можно либо использовать как есть,
либо добавить в свою систему.

## Использование в конфигурации

Добавьте input в свой флейк и подгоните его `nixpkgs` под свой, чтобы оба
корня шарили одну ревизию:

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

Системная установка (NixOS):

```nix
{ pkgs, inputs, ... }: {
  environment.systemPackages = [
    inputs.ayugram-desktop.packages.${pkgs.system}.default
  ];
}
```

Или для пользователя (Home Manager):

```nix
{ pkgs, inputs, ... }: {
  home.packages = [
    inputs.ayugram-desktop.packages.${pkgs.system}.default
  ];
}
```

> После `nixos-rebuild switch` или `home-manager switch` запускайте
> **AyuGram**.

## Кэши, ручная настройка

Описанные выше кэши обычно подхватываются автоматически из `nixConfig`
флейка. Если ваш Nix-демон их игнорирует — настройте сами:

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

**Это переопределяет `telegram-desktop`?**
Нет — AyuGram собирается из собственного дерева. Значит и сломанный апдейт
`tdesktop` на него не влияет.

**Какие платформы поддерживаются?**
`x86_64-linux` и `aarch64-linux`. Остальные без CI и тестового устройства.

**А что с отчётами о падениях?**
Без изменений. Идут туда, куда AyuGram отправляет их обычно; ничего не
перенаправляется.

## Мейнтейнеры

Флейк поддерживают **[hand7s](https://github.com/s0me1newithand7s)** и
**[fractal](https://github.com/fractal-l)**. Вклад в код и отчёты о сборках
приветствуются.

## Лицензия

Сам флейк распространяется под [GPL-3.0-or-later](./LICENSE), как и AyuGram.
AyuGramDesktop распространяется на тех же условиях его
[авторами](https://github.com/AyuGram/AyuGramDesktop).