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
  gitUpdater,
  isDebug ? false,
  tg_owt ? callPackage ./lib/tg_owt.nix { inherit stdenv; },
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ayugram-desktop-unwrapped";
  version = "5.11.1";

  src = fetchFromGitHub {
    owner = "AyuGram";
    repo = "AyuGramDesktop";
    rev = "v${finalAttrs.version}";

    fetchSubmodules = true;
    hash = "sha256-AiMPbcEvbyhGd1V9mg95Q+mLrBH0DqTEFpC3D9ziCy8=";
  };

  patches = [
    ./patch/cstring.patch
    # Fixes linux builds
    (fetchpatch {
      url = "https://github.com/AyuGram/AyuGramDesktop/pull/32/commits/15287ad6ed162c209d9772fc592e959d793f63b9.patch";
      hash = "sha256-3yt502TsytJtpBn8iSJySN+UAQQ23c1hYNPIFLSogVA=";
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
    (lib.cmakeBool "DESKTOP_APP_DISABLE_AUTOUPDATE" true)

    (lib.cmakeFeature "TDESKTOP_API_HASH" "b18441a1ff607e10a989891a5462e627")
    (lib.cmakeFeature "TDESKTOP_API_ID" "2040")

    (lib.cmakeFeature "CMAKE_BUILD_TYPE" (if isDebug then "Debug" else "Release"))
  ];

  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r ${finalAttrs.meta.mainProgram}.app $out/Applications
    ln -sr $out/{Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS,bin}

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    url = "https://github.com/AyuGram/AyuGramDesktop.git";
  };

  meta = with lib; {
    mainProgram = "ayugram-desktop";

    # inherit from AyuGramDesktop
    maintainers = with maintainers; [
      kaeeraa
      s0me1newithhand7s
    ];
    platforms = lib.platforms.linux;
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
