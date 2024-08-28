let
  system = builtins.currentSystem;
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { inherit system; };
in
{ # tysm shwewo
  system ? builtins.currentSystem,
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
  wrapGAppsHook3 ? pkgs.wrapGAppsHook3,
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
  microsoft-gsl ? pkgs.microsoft_gsl,
  rlottie ? pkgs.rlottie,
  darwin ? pkgs.darwin,
  lld ? pkgs.lld,
  libicns ? pkgs.libicns,
  nix-update-script ? pkgs.nix-update-script,
  libXtst ? pkgs.xorg.libXtst,
  libclang ? pkgs.libclang,
  clang ? pkgs.clang,
  kcoreaddons ? pkgs.libsForQt5.kcoreaddons,
  mount ? pkgs.mount,
  xdmcp ? pkgs.xorg.libXdmcp,
  ada ? pkgs.ada,
  glib-networking ? pkgs.glib-networking,
  pcre ? pkgs.pcre,
  pcre-cpp ? pkgs.pcre-cpp,
}:


# Main reference:
# - This package was originally based on the Arch package but all patches are now upstreamed:
#   https://git.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/telegram-desktop
# Other references that could be useful:
# - https://git.alpinelinux.org/aports/tree/testing/telegram-desktop/APKBUILD
# - https://github.com/void-linux/void-packages/blob/master/srcpkgs/telegram-desktop/template

let
  mainProgram = if stdenv.isLinux then "ayugram-desktop" else "Ayugram";

  pname = "AyuGramDesktop";
  version = "5.4.1";

  tg_owt = callPackage ./tg_owt.nix {
    inherit stdenv;
    abseil-cpp = abseil-cpp.override {
      cxxStandard = "20";
    };
  };


in
stdenv.mkDerivation (finalAttrs: {
  pname = "${pname}";
  version = "${version}";

  src = fetchFromGitHub {
    owner = "AyuGram";
    repo = "${pname}";
    rev = "v${version}";

    fetchSubmodules = true;
    hash = "sha256-7KmXA3EDlCszoUfQZg3UsKvfRCENy/KLxiE08J9COJ8=";
  };

  # ok, now darwin support
  patches = [
    ./macos.patch
    ./scheme.patch
  ];

  postPatch = lib.optionalString stdenv.isLinux ''
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioInputALSA.cpp \
      --replace-fail '"libasound.so.2"' '"${alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioOutputALSA.cpp \
      --replace-fail '"libasound.so.2"' '"${alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioPulse.cpp \
      --replace-fail '"libpulse.so.0"' '"${libpulseaudio}/lib/libpulse.so.0"'
    substituteInPlace Telegram/lib_webview/webview/platform/linux/webview_linux_webkitgtk_library.cpp \
      --replace-fail '"libwebkitgtk-6.0.so.4"' '"${webkitgtk_6_0}/lib/libwebkitgtk-6.0.so.4"'
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace Telegram/lib_webrtc/webrtc/platform/mac/webrtc_environment_mac.mm \
      --replace-fail kAudioObjectPropertyElementMain kAudioObjectPropertyElementMaster
  '';

  # We want to run wrapProgram manually (with additional parameters)
  dontWrapGApps = true;
  dontWrapQtApps = true;

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    python3
    wrapQtAppsHook
    clang
    libclang
  ] ++ lib.optionals stdenv.isLinux [
    gobject-introspection
    wrapGAppsHook3
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
    ada
    clang
    libclang
    kcoreaddons
    mount
    xdmcp
    pcre
    pcre-cpp
  ] ++ lib.optionals stdenv.isLinux [
    qtwayland
    gtk3
    glib-networking
    fmt
    libdbusmenu
    alsa-lib
    libpulseaudio
    pipewire
    hunspell
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
    LocalAuthentication
    libicns
  ]);
  
  enableParallelBuilding = true;

  env = lib.optionalAttrs stdenv.isDarwin {
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
    PKG_CONFIG_PATH = "$PKG_CONFIG_PATH:$(which mount)";
  };

  cmakeFlags = [
    "-Ddisable_autoupdate=ON"
    "-DTDESKTOP_API_ID=2040"
    "-DTDESKTOP_API_HASH=b18441a1ff607e10a989891a5462e627"
    "-DDESKTOP_APP_USE_GTK3=ON"
    # See: https://github.com/NixOS/nixpkgs/pull/130827#issuecomment-885212649
    "-DDESKTOP_APP_USE_PACKAGED_FONTS=OFF"
    "-DDESKTOP_APP_DISABLE_SCUDO=ON"
  ];

  preBuild = ''
    # for cppgir to locate gir files
    export GI_GIR_PATH="$XDG_DATA_DIRS"
  '';

  installPhase = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    cp -r ${finalAttrs.meta.mainProgram}.app $out/Applications
    ln -s $out/{Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS,bin}
  '';

  preFixup = ''
    remove-references-to -t ${stdenv.cc.cc} $out/bin/${mainProgram}
    remove-references-to -t ${microsoft-gsl} $out/bin/${mainProgram}
    remove-references-to -t ${tg_owt.dev} $out/bin/${mainProgram}
  '';

  postFixup = lib.optionalString stdenv.isLinux ''
    # This is necessary to run Telegram in a pure environment.
    # We also use gappsWrapperArgs from wrapGAppsHook.
    wrapProgram $out/bin/${finalAttrs.meta.mainProgram} \
      "''${gappsWrapperArgs[@]}" \
      "''${qtWrapperArgs[@]}" \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '' + lib.optionalString stdenv.isDarwin ''
    wrapQtApp $out/Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS/${finalAttrs.meta.mainProgram}
  '';


  passthru = {
    inherit tg_owt;
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Desktop Telegram client with good customization and Ghost mode.";
    license = licenses.gpl3Only;
    platforms = lib.platforms.all;
    homepage = "https://ayugram.one";
    changelog = "https://github.com/Ayugram/AyuGramDesktop/releases/tag/v${version}";
    maintainers = with maintainers; [ ];
    inherit mainProgram;
  };
})