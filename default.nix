{ # ty shwewo
  pkgs ? import <nixpkgs> { system = builtins.currentSystem; config.allowUnfree = true; },
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
}:

# Main reference:
# - This package was originally based on the Arch package but all patches are now upstreamed:
#   https://git.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/telegram-desktop
# Other references that could be useful:
# - https://git.alpinelinux.org/aports/tree/testing/telegram-desktop/APKBUILD
# - https://github.com/void-linux/void-packages/blob/master/srcpkgs/telegram-desktop/template

let
  tg_owt = callPackage ./tg_owt.nix {
    inherit stdenv;
    abseil-cpp = abseil-cpp.override {
      cxxStandard = "20";
    };
  };
  mainProgram = if stdenv.isLinux then "ayugram-desktop" else "ayugram";
in
stdenv.mkDerivation rec {
  pname = "ayugram-desktop";
  version = "5.2.2";

  src = fetchFromGitHub {
    owner = "AyuGram";
    repo = "AyuGramDesktop";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-XaywX/kxRxN7vkItsvNGexjoukfAyyvEVMrn1Vy7U54=";
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
  ] ++ lib.optionals stdenv.isLinux [
    gobject-introspection
    wrapGAppsHook
    extra-cmake-modules
  ] ++ lib.optionals stdenv.isDarwin [
    lld
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
  ] ++ lib.optionals stdenv.isLinux [
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
  ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk_11_0.frameworks; [
    Cocoa
    CoreFoundation
    CoreServices
    CoreText
    CoreGraphics
    CoreMedia
    OpenGL
    AudioUnit
    ApplicationServices
    Foundation
    AGL
    Security
    SystemConfiguration
    Carbon
    AudioToolbox
    VideoToolbox
    VideoDecodeAcceleration
    AVFoundation
    CoreAudio
    CoreVideo
    CoreMediaIO
    QuartzCore
    AppKit
    CoreWLAN
    WebKit
    IOKit
    GSS
    MediaPlayer
    IOSurface
    Metal
    NaturalLanguage
    libicns
  ]);

  env = lib.optionalAttrs stdenv.isDarwin {
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  cmakeFlags = [
    "-Ddisable_autoupdate=ON"
    # We're allowed to used the API ID of the Snap package:
    "-DTDESKTOP_API_ID=611335"
    "-DTDESKTOP_API_HASH=d524b414d21f4d37f08684c1df41ac9c"
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

  installPhase = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    cp -r ${mainProgram}.app $out/Applications
    ln -s $out/{Applications/${mainProgram}.app/Contents/MacOS,bin}
  '';

  postFixup = lib.optionalString stdenv.isLinux ''
    sed -i 's/Exec=DESKTOPINTEGRATION=1 ayugram-desktop -- %u/Exec=ayugram-desktop -- %u/g' "$out/share/applications/com.ayugram.desktop.desktop"
    sed -i 's/StartupWMClass=AyuGram/StartupWMClass=com.ayugram/g' "$out/share/applications/com.ayugram.desktop.desktop"
    
    # This is necessary to run Telegram in a pure environment.
    # We also use gappsWrapperArgs from wrapGAppsHook.
    wrapProgram $out/bin/${mainProgram} \
      "''${gappsWrapperArgs[@]}" \
      "''${qtWrapperArgs[@]}" \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '' + lib.optionalString stdenv.isDarwin ''
    wrapQtApp $out/Applications/${mainProgram}.app/Contents/MacOS/${mainProgram}
  ''; 

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