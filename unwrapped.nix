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
  qtsvg,
  qtwayland,
  kcoreaddons,
  lz4,
  xxHash,
  ffmpeg_6,
  protobuf,
  openalSoft,
  minizip,
  range-v3,
  tl-expected,
  hunspell,
  gobject-introspection,
  rnnoise,
  microsoft-gsl,
  boost,
  ada,
  libicns,
  apple-sdk_15,
  qtbase,
  tdlib,
  nix-update-script,
  fetchpatch2,
  isDebug ? false,
  tg_owt ? callPackage ./lib/tg_owt.nix {inherit stdenv;},
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ayugram-desktop-unwrapped";
  version = "6.2.4";

  src = fetchFromGitHub {
    owner = "AyuGram";
    repo = "AyuGramDesktop";
    rev = "v${finalAttrs.version}";

    fetchSubmodules = true;
    hash = "sha256-Q7CVNU97wdEk+bMvOyMn8b0Ov8WHSdbAP+JYnqfrmM8=";
  };

  # fix build failure with Qt 6.10
  patches = fetchpatch2 {
    name = "fix-build-with-qt-610.patch";
    url = "https://github.com/desktop-app/cmake_helpers/commit/682f1b57.patch";
    hash = "sha256-DHwgxAEFc1byQkVvrPwyctQKvUsK/KQ/cnzRv6PQuTM=";
    stripLen = 1;
    extraPrefix = "cmake/";
  };

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
      qtsvg
      lz4
      xxHash
      ffmpeg_6
      openalSoft
      minizip
      range-v3
      tl-expected
      rnnoise
      tg_owt
      microsoft-gsl
      boost
      ada
      (tdlib.override {tde2eOnly = true;})
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      protobuf
      qtwayland
      kcoreaddons
      hunspell
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      apple-sdk_15
      libicns
    ];

  cmakeFlags = [
    (lib.cmakeBool "DESKTOP_APP_DISABLE_AUTOUPDATE" true)

    (lib.cmakeFeature "TDESKTOP_API_ID" "611335")
    (lib.cmakeFeature "TDESKTOP_API_HASH" "d524b414d21f4d37f08684c1df41ac9c")

    (lib.cmakeFeature "CMAKE_BUILD_TYPE" (
      if isDebug
      then "Debug"
      else "Release"
    ))
  ];

  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r ${finalAttrs.meta.mainProgram}.app $out/Applications
    ln -sr $out/{Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS,bin}

    runHook postInstall
  '';

  passthru = {
    inherit tg_owt;
    updateScript = nix-update-script {};
  };

  meta = with lib; {
    mainProgram = "ayugram-desktop";

    # inherit from AyuGramDesktop
    maintainers = with maintainers; [
      kaeeraa
      s0me1newithhand7s
    ];
    platforms = lib.platforms.all;
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
