{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  callPackage,
  pkg-config,
  cmake,
  ninja,
  python3,
  gobject-introspection,
  wrapGAppsHook3,
  wrapQtAppsHook,
  extra-cmake-modules,
  qtbase,
  qtwayland,
  qtsvg,
  qtimageformats,
  gtk3,
  boost,
  fmt,
  libdbusmenu,
  lz4,
  xxHash,
  ffmpeg,
  openalSoft,
  minizip,
  libopus,
  alsa-lib,
  libpulseaudio,
  pipewire,
  range-v3,
  tl-expected,
  hunspell,
  glibmm_2_68,
  webkitgtk_6_0,
  jemalloc,
  rnnoise,
  protobuf,
  abseil-cpp,
  xdg-utils,
  microsoft-gsl,
  rlottie,
  darwin,
  lld,
  libicns,
  nix-update-script,
  libXtst,
  libclang,
  clang,
  kcoreaddons,
  mount,
  ada,
  glib-networking,
  pcre,
  pcre-cpp,
  makeWrapper,
  fetchgit,
}:

let
  mainProgram = if stdenv.isLinux then "ayugram-desktop" else "Ayugram";

  tg_owt = fetchgit {
    url = "https://github.com/kaeeraa/tg_owt.git";
    hash = "sha256-Hu8Kz2MidIyKaUtsDWhkzlpDJEm+OwzanE9fIUxgJRE=";
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "ayugram-desktop";
  version = "5.4.1";

  src = fetchFromGitHub {
    owner = "AyuGram";
    repo = "AyuGramDesktop";
    rev = "v5.4.1";

    fetchSubmodules = true;
    hash = "sha256-7KmXA3EDlCszoUfQZg3UsKvfRCENy/KLxiE08J9COJ8=";
  };

  patches =
    [ ./patch/desktop.patch ]
    ++ lib.optionals stdenv.isDarwin [
      ./patch/macos.patch
      ./patch/macos-opengl.patch
    ];

  postPatch = lib.optionalString stdenv.isLinux ''
    for file in \
      Telegram/ThirdParty/libtgvoip/os/linux/AudioInputALSA.cpp \
      Telegram/ThirdParty/libtgvoip/os/linux/AudioOutputALSA.cpp \
      Telegram/ThirdParty/libtgvoip/os/linux/AudioPulse.cpp \
      Telegram/lib_webview/webview/platform/linux/webview_linux_webkitgtk_library.cpp
    do
      substituteInPlace "$file" \
        --replace '"libasound.so.2"' '"${alsa-lib}/lib/libasound.so.2"' \
        --replace '"libpulse.so.0"' '"${libpulseaudio}/lib/libpulse.so.0"' \
        --replace '"libwebkitgtk-6.0.so.4"' '"${webkitgtk_6_0}/lib/libwebkitgtk-6.0.so.4"'
    done
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace Telegram/lib_webrtc/webrtc/platform/mac/webrtc_environment_mac.mm \
      --replace kAudioObjectPropertyElementMain kAudioObjectPropertyElementMaster
  '';

  # Wrapping the inside of the app bundles, avoiding double-wrapping
  dontWrapQtApps = stdenv.isDarwin;

  nativeBuildInputs =
    [
      cmake
      ninja
      pkg-config
      python3
      wrapQtAppsHook
      clang
      libclang
    ];

  buildInputs =
    [
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
      kcoreaddons
      mount
      pcre
      pcre-cpp
      libXtst
    ];

  propagatedBuildInputs =
    lib.optionals stdenv.isLinux [
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
    ];

  darwinFrameworks =
    lib.optionals stdenv.isDarwin (
      with darwin.apple_sdk_11_0.frameworks;
      [
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
      ]
    );

  # On darwin, we need to use lld as the linker, as otherwise the linking step
  # will fail due to missing symbols.
  makeFlags = lib.optionalString stdenv.isDarwin "NIX_CFLAGS_LINK=-fuse-ld=lld";

  cmakeFlags = [
    "-Ddisable_autoupdate=ON"
    "-DTDESKTOP_API_ID=2040"
    "-DTDESKTOP_API_HASH=b18441a1ff607e10a989891a5462e627"
    "-DDESKTOP_APP_USE_GTK3=ON"
    "-DDESKTOP_APP_USE_PACKAGED_FONTS=OFF"
    "-DDESKTOP_APP_DISABLE_SCUDO=ON"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_CXX_FLAGS=-O3"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    "-DCMAKE_GENERATOR=Ninja"
  ];

  preBuild = lib.optionalString stdenv.isLinux ''
    export GI_GIR_PATH=${webkitgtk_6_0}/share/gir-1.0
  '';

  installPhase = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    cp -r ${finalAttrs.meta.mainProgram}.app $out/Applications
    ln -s $out/Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS/${finalAttrs.meta.mainProgram} $out/bin/${finalAttrs.meta.mainProgram}
  '';

  postFixup = lib.optionalString stdenv.isLinux ''
    wrapProgram $out/bin/${finalAttrs.meta.mainProgram} \
      --prefix GIO_EXTRA_MODULES : ${glib-networking}/lib/gio/modules \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ webkitgtk_6_0 ]}
  '' + lib.optionalString stdenv.isDarwin ''
    wrapQtApp $out/Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS/${finalAttrs.meta.mainProgram}
  '';

  passthru = {
    inherit tg_owt;
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    inherit mainProgram;

    # inherit from AyuGramDesktop
    description = "Desktop Telegram client with good customization and Ghost mode.";
    license = licenses.gpl3Only;
    platforms = lib.platforms.all;
    homepage = "https://ayugram.one";
    changelog = "https://github.com/Ayugram/AyuGramDesktop/releases/tag/v${version}";
    maintainers = with maintainers; [ ];
    broken = stdenv.isDarwin; # temporary
    badPlatforms = [ stdenv.isDarwin ];
    downloadPage = "https://github.com/Ayugram/AyuGramDesktop/releases/tag/v${version}";
    longDescription = ''
      AyuGram is a fork of Telegram Desktop with a focus on
      customization. It includes features like a customizable
      interface, Ghost mode, and more.
    '';
  };
})


