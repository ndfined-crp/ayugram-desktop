{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  pkg-config,
  cmake,
  ninja,
  clang,
  python3,
  libsForQt5,
  qtimageformats,
  qtsvg,
  qtwayland,
  kcoreaddons,
  lz4,
  xxHash,
  ffmpeg_6,
  protobuf,
  openalSoft,
  minizip,
  libopus,
  alsa-lib,
  libpulseaudio,
  range-v3,
  tl-expected,
  hunspell,
  gobject-introspection,
  jemalloc,
  rnnoise,
  microsoft-gsl,
  boost,
  ada,
  libicns,
  apple-sdk_15,
  nix-update-script,
  fetchpatch,
  tg_owt ? callPackage ./lib/tg_owt.nix { inherit stdenv; },
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ayugram-desktop-unwrapped";
  version = "5.10.3";

  src = fetchFromGitHub {
    owner = "AyuGram";
    repo = "AyuGramDesktop";
    rev = "v${finalAttrs.version}";

    fetchSubmodules = true;
    hash = "sha256-ieHIBBm97ZZ+5EK4k3QTkhrazHnhiLNXpQoQFtzn8KY=";
  };

  patches = [
    ./patch/cstring.patch
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
      libsForQt5.qt5.qtbase
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
    (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
    (lib.cmakeFeature "CMAKE_GENERATOR" "Ninja")

    (lib.cmakeBool "DESKTOP_APP_DISABLE_AUTOUPDATE" true)
    (lib.cmakeBool "DESKTOP_APP_DISABLE_SCUDO" true)
    (lib.cmakeBool "DESKTOP_APP_USE_GTK3" true)

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
