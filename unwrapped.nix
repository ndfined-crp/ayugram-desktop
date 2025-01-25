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
  tg_owt ? callPackage ./lib/tg_owt.nix { inherit stdenv; },
  system ? builtins.currentSystem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ayugram-desktop-unwrapped";
  version = "5.8.3";

  src = fetchFromGitHub {
    owner = "AyuGram";
    repo = "AyuGramDesktop";
    rev = "v${finalAttrs.version}";

    fetchSubmodules = true;
    hash = "sha256-bgfqYI77kxHmFZB6LCdLzeIFv6bfsXXJrrkbz5MD6Q0=";
  };

  patches = [
    ./patch/cstring.patch
    (fetchpatch {
      url = "https://github.com/AyuGram/AyuGramDesktop/commit/8847034217487d992cd070c0ab791baa213b4141.patch";
      hash = "sha256-8q+K06wmG6TuBRomDSS9zWuM3PYQfMHpmIokw+bC3EY=";
    })
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioInputALSA.cpp \
      --replace-fail '"libasound.so.2"' '"${lib.getLib alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioOutputALSA.cpp \
      --replace-fail '"libasound.so.2"' '"${lib.getLib alsa-lib}/lib/libasound.so.2"'
    substituteInPlace Telegram/ThirdParty/libtgvoip/os/linux/AudioPulse.cpp \
      --replace-fail '"libpulse.so.0"' '"${lib.getLib libpulseaudio}/lib/libpulse.so.0"'
    substituteInPlace lib/xdg/com.ayugram.desktop.desktop \
              --replace-fail "DBusActivatable=true" ""
  '';

  dontWrapQtApps = true;

  nativeBuildInputs =
    [
      pkg-config
      cmake
      ninja
      python3
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      # to build bundled libdispatch
      clang
      gobject-introspection
    ];

  buildInputs =
    [
      qtbase
      qtimageformats
      qtsvg
      lz4
      xxHash
      ffmpeg_6
      openalSoft
      minizip
      libopus
      range-v3
      tl-expected
      rnnoise
      tg_owt
      microsoft-gsl
      boost
      ada
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      protobuf
      qtwayland
      kcoreaddons
      alsa-lib
      libpulseaudio
      hunspell
      jemalloc
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      apple-sdk_15
      libicns
    ];

  cmakeFlags = [
    (lib.cmakeBool "CMAKE_EXPORT_COMPILE_COMMANDS" true)
    (lib.cmakeBool "CMAKE_BUILD_TYPE" "Release")
    (lib.cmakeFeature "CMAKE_GENERATOR" "Ninja")

    (lib.cmakeBool "DESKTOP_APP_DISABLE_AUTOUPDATE" true)
    (lib.cmakeFeature "DESKTOP_APP_DISABLE_SCUDO" true)
    (lib.cmakeFeature "DESKTOP_APP_USE_GTK3" true)

    (lib.cmakeBool "DESKTOP_APP_USE_PACKAGED_FONTS" false)

    (lib.cmakeFeature "TDESKTOP_API_HASH" "b18441a1ff607e10a989891a5462e627")
    (lib.cmakeFeature "TDESKTOP_API_ID" "2040")
  ];

  # for cppgir to locate gir files
  preBuild = ''
    export GI_GIR_PATH="$XDG_DATA_DIRS"
  '';

  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r ${finalAttrs.meta.mainProgram}.app $out/Applications
    ln -sr $out/{Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS,bin}

    runHook postInstall
  '';

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
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
