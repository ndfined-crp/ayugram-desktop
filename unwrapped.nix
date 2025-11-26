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
  qtbase,
  tdlib,
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
    hash = "sha256-bFGk8lqPlNlaxbrulYe0+8ayj33frctruce3/TZ+W2c=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    python3
    clang
    gobject-introspection
  ];
  buildInputs = [
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
    protobuf
    qtwayland
    kcoreaddons
    hunspell
  ];

  dontWrapQtApps = true;
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

  meta = with lib; {
    mainProgram = "ayugram-desktop";
    maintainers = with maintainers; [kaeeraa s0me1newithhand7s];
    platforms = with platforms; builtins.filter (x: x != darwin) all;
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
