{ # tysm shwewo
  pkgs ? import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/tarball/bd29cb4b3004a482a2c5917de7525a762fecdc7e) { system = builtins.currentSystem; },
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  fetchpatch ? pkgs.fetchpatch,
  callPackage ? pkgs.callPackage,
  pkg-config ? pkgs.pkg-config,
  cmake ? pkgs.cmake,
  ninja ? pkgs.ninja,
  python3 ? pkgs.python3,
  gobject-introspection ? pkgs.gobject-introspection,
  wrapGAppsHook ? pkgs.wrapGAppsHook,
  wrapQtAppsHook ? pkgs.libsForQt5.qt5.wrapQtAppsHook,
  extra-cmake-modules ? pkgs.extra-cmake-modules,
  qtbase ? pkgs.libsForQt5.qt5.qtbase,
  qtwayland ? pkgs.libsForQt5.qt5.qtwayland,
  qtsvg ? pkgs.libsForQt5.qt5.qtsvg,
  qtimageformats ? pkgs.libsForQt5.qt5.qtimageformats,
  gtk3 ? pkgs.gtk3,
  boost ? pkgs.boost,
  fmt ? pkgs.fmt,
  libdbusmenu ? pkgs.libdbusmenu,
  lz4 ? pkgs.lz4,
  xxHash ? pkgs.xxHash,
  ffmpeg ? pkgs.ffmpeg,
  openalSoft ? pkgs.openalSoft,
  minizip ? pkgs.minizip,
  libopus ? pkgs.libopus,
  alsa-lib ? pkgs.alsa-lib,
  libpulseaudio ? pkgs.libpulseaudio,
  pipewire ? pkgs.pipewire,
  range-v3 ? pkgs.range-v3,
  tl-expected ? pkgs.tl-expected,
  hunspell ? pkgs.hunspell,
  glibmm_2_68 ? pkgs.glibmm_2_68,
  webkitgtk_6_0 ? pkgs.webkitgtk_6_0,
  jemalloc ? pkgs.jemalloc,
  rnnoise ? pkgs.rnnoise,
  protobuf ? pkgs.protobuf,
  abseil-cpp ? pkgs.abseil-cpp,
  xdg-utils ? pkgs.xdg-utils,
  microsoft-gsl ? pkgs.microsoft-gsl,
  rlottie ? pkgs.rlottie,
  darwin ? pkgs.darwin,
  lld ? pkgs.lld,
  libicns ? pkgs.libicns,
  nix-update-script ? pkgs.nix-update-script,
  libXtst ? pkgs.xorg.libXtst,
  libclang ? pkgs.libclang,
  kcoreaddons ? pkgs.libsForQt5.kcoreaddons,
  mount ? pkgs.mount,
  xdmcp ? pkgs.xorg.libXdmcp,
  ada ? pkgs.ada,
}:

# Main reference:
# - This package was originally based on the Arch package but all patches are now upstreamed:
#   https://git.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/telegram-desktop
# Other references that could be useful:
# - https://git.alpinelinux.org/aports/tree/testing/telegram-desktop/APKBUILD
# - https://github.com/void-linux/void-packages/blob/master/srcpkgs/telegram-desktop/template

let
  mainProgram = "ayugram-desktop";

  tg_owt = callPackage ./tg_owt.nix {
    inherit stdenv;
    abseil-cpp = abseil-cpp.override {
      cxxStandard = "20";
    };
  };
in
stdenv.mkDerivation rec {
  pname = "ayugram-desktop";
  version = "5.4.1";

  src = fetchFromGitHub {
    owner = "AyuGram";
    repo = "AyuGramDesktop";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-7KmXA3EDlCszoUfQZg3UsKvfRCENy/KLxiE08J9COJ8=";
  };

  # no patches, because: 1. i dont have mac, 2. patches breaking building

  # We want to run wrapProgram manually (with additional parameters)
  dontWrapGApps = true;
  dontWrapQtApps = true;

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    python3
    wrapQtAppsHook
    gobject-introspection
    wrapGAppsHook
    extra-cmake-modules
  ];

  buildInputs = [
    qtbase
    qtsvg
    qtimageformats
    boost
    lz4
    xxHash
    ffmpeg
    openalSoft
    minizip
    libopus
    range-v3
    tl-expected
    rnnoise
    protobuf
    tg_owt
    microsoft-gsl
    rlottie
    libXtst
    qtwayland
    gtk3
    fmt
    libdbusmenu
    alsa-lib
    libpulseaudio
    pipewire
    hunspell
    glibmm_2_68
    webkitgtk_6_0
    jemalloc
    libclang
    kcoreaddons
    mount
    xdmcp
    ada
  ];

  cmakeFlags = [
    "-Ddisable_autoupdate=ON"
    "-DTDESKTOP_API_ID=2040"
    "-DTDESKTOP_API_HASH=b18441a1ff607e10a989891a5462e627"
    "-DDESKTOP_APP_USE_GTK3=ON"
    # See: https://github.com/NixOS/nixpkgs/pull/130827#issuecomment-885212649
    "-DDESKTOP_APP_USE_PACKAGED_FONTS=OFF"
    "-DDESKTOP_APP_DISABLE_SCUDO=ON"
  ];
  CXXFLAGS = [ 
    # GCC 13: error: 'int64_t' in namespace 'std' does not name a type
    "-include cstdint"
  ];

  preBuild = ''
    # for cppgir to locate gir files
    export GI_GIR_PATH="$XDG_DATA_DIRS"
  '';

  postFixup = ''
    sed -i 's/Exec=DESKTOPINTEGRATION=1 ayugram-desktop -- %u/Exec=ayugram-desktop -- %u/g' "$out/share/applications/com.ayugram.desktop.desktop"
    sed -i 's/StartupWMClass=AyuGram/StartupWMClass=com.ayugram/g' "$out/share/applications/com.ayugram.desktop.desktop"
    
    # This is necessary to run Telegram in a pure environment.
    # We also use gappsWrapperArgs from wrapGAppsHook.
    wrapProgram $out/bin/${mainProgram} \
      "''${gappsWrapperArgs[@]}" \
      "''${qtWrapperArgs[@]}" \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]} '';

  passthru = {
    inherit tg_owt;
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Desktop Telegram client with good customization and Ghost mode.";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    homepage = "https://github.com/AyuGram/AyuGramDesktop";
    changelog = "https://github.com/Ayugram/AyuGramDesktop/releases/tag/v${version}";
    maintainers = with maintainers; [ ];
    inherit mainProgram;
  };
}