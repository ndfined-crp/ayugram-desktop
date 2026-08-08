{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  cmake,
  ninja,
  cmark-gfm,
  python3,
  qtsvg,
  qtwayland,
  kcoreaddons,
  lz4,
  xxhash,
  ffmpeg_6,
  protobuf,
  openal-soft,
  minizip-ng-compat,
  qtshadertools,
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
  tg_owt,
  isDebug ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ayugram-desktop-unwrapped";
  version = "7.0.9";
# Full release archive is used because it bundles submodules (codegen).
  # This also avoids the official v7.0.9 tag pointing to a broken submodule
  # pin that fails to build on Linux.
  # If the archive is re-uploaded, update the hash below.
  src = fetchurl {
    url = "https://github.com/AyuGram/AyuGramDesktop/releases/download/v${finalAttrs.version}/AyuGramDesktop-${finalAttrs.version}-full.tar.gz";
    hash = "sha256-znTEAOSI/JDTeE87o9YCyv7NUFO3onOll3GGg6R6uw8=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    python3
    gobject-introspection
  ];
  buildInputs = [
    qtbase
    qtsvg
    lz4
    xxhash
    ffmpeg_6
    openal-soft
    minizip-ng-compat
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
    qtshadertools
    cmark-gfm
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
    mainProgram = "AyuGram";
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
