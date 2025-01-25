{
  lib,
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
  qtwayland,
  qtsvg,
  qtimageformats,
  gtk3,
  glib-networking,
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
  webkitgtk_4_1,
  jemalloc,
  rnnoise,
  protobuf,
  abseil-cpp,
  xdg-utils,
  microsoft-gsl,
  rlottie,
  ada,
  stdenv,
  darwin,
  lld,
  libicns,
  nix-update-script,
  clang,
  libclang,
  glib,
  libXi,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrender,
  libXrandr,
  libXtst,
  pcre,
  pcre-cpp,
  openssl,
  libjpeg,
  libsForQt5,
  system ? builtins.currentSystem,
}:
let
  tg_owt = callPackage ./lib/tg_owt.nix {
    inherit stdenv; # oh no, stdenv
    abseil-cpp = abseil-cpp.override { cxxStandard = "20"; };
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ayugram-desktop";
  version = "5.8.3";

  src = fetchFromGitHub {
    owner = "AyuGram";
    repo = "AyuGramDesktop";
    rev = "v${finalAttrs.version}";

    fetchSubmodules = true;
    hash = "sha256-bgfqYI77kxHmFZB6LCdLzeIFv6bfsXXJrrkbz5MD6Q0=";
  };

  patches =
    [
      ./patch/cstring.patch
      (fetchpatch {
        url = "https://github.com/AyuGram/AyuGramDesktop/commit/8847034217487d992cd070c0ab791baa213b4141.patch";
        hash = "sha256-8q+K06wmG6TuBRomDSS9zWuM3PYQfMHpmIokw+bC3EY=";
      })
    ]
    ++ lib.optionals stdenv.isDarwin [
      ./patch/macos.patch
    ];

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioInputALSA.cpp \
      --replace-fail '"libasound.so.2"' '"${lib.getLib alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioOutputALSA.cpp \
      --replace-fail '"libasound.so.2"' '"${lib.getLib alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioPulse.cpp \
      --replace-fail '"libpulse.so.0"' '"${lib.getLib libpulseaudio}/lib/libpulse.so.0"'
  '';

  qtWrapperArgs = lib.optionals stdenv.hostPlatform.isLinux [
    "--prefix"
    "LD_LIBRARY_PATH"
    ":"
    (lib.makeLibraryPath [ webkitgtk_4_1 ])
  ];

  # We want to run wrapProgram manually (with additional parameters)
  dontWrapGApps = true;
  dontWrapQtApps = true;

  nativeBuildInputs =
    [
      cmake
      ninja
      pkg-config
      python3
      wrapQtAppsHook
      clang
      libclang
      pkg-config
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      gobject-introspection
      wrapGAppsHook3
      extra-cmake-modules
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      lld
    ];

  buildInputs = [
    libsForQt5.qt5.qtbase
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
    pcre
    pcre-cpp
    libXtst
    openssl
    libjpeg
    libopus
    ffmpeg
    libXdamage
    ada
  ];

  propagatedBuildInputs = lib.optionals stdenv.isLinux [
    qtwayland
    gtk3
    glib-networking
    fmt
    libdbusmenu
    alsa-lib
    libpulseaudio
    pipewire
    hunspell
    webkitgtk_4_1
    jemalloc
    tg_owt
    glib
    libXi
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrender
    libXrandr
    libXtst
    pipewire
  ];

  darwinFrameworks = lib.optionals stdenv.isDarwin (
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
    "-DDESKTOP_APP_DISABLE_AUTOUPDATE=ON"
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

  # for cppgir to locate gir files
  preBuild = ''
    export GI_GIR_PATH="$XDG_DATA_DIRS"
  '';

  installPhase = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    cp -r ${finalAttrs.meta.mainProgram}.app $out/Applications
    ln -s $out/Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS/${finalAttrs.meta.mainProgram} $out/bin/${finalAttrs.meta.mainProgram}
  '';

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  # This is necessary to run Telegram in a pure environment.
  # We also use gappsWrapperArgs from wrapGAppsHook.
  postFixup =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapProgram $out/bin/${finalAttrs.meta.mainProgram} \
        "''${gappsWrapperArgs[@]}" \
        "''${qtWrapperArgs[@]}" \
        --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      wrapQtApp $out/Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS/${finalAttrs.meta.mainProgram}
    '';

  passthru = {
    inherit tg_owt;
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    mainProgram = "ayugram-desktop";

    # inherit from AyuGramDesktop
    maintainers = with maintainers; [ ];
    platforms = lib.platforms.all;
    broken = stdenv.isDarwin; # temporary
    badPlatforms = [ stdenv.isDarwin ];
    description = "Desktop Telegram client with good customization and Ghost mode.";
    license = licenses.gpl3Only;
    homepage = "https://ayugram.one";
    downloadPage = "https://github.com/Ayugram/AyuGramDesktop/releases/tag/v${version}";
    changelog = "https://github.com/Ayugram/AyuGramDesktop/releases/tag/v${version}";
    longDescription = ''
      AyuGram is a fork of Telegram Desktop with a focus on
      customization. It includes features like a customizable
      interface, Ghost mode, and more.
    '';
  };
})

