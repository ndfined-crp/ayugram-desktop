{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

# Vendored because the pinned nixpkgs has no `tlottie` package yet
# (it appeared upstream later). Mirrors nixpkgs' package for the same
# desktop-app toolkit generation used by telegram-desktop 7.2.x.
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tlottie";
  version = "0-unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "dkaraush";
    repo = "tlottie";
    rev = "31f1b542f88e7b4be9a01e749920d857535fc715";
    hash = "sha256-JsRB0VfYTXgtgwape1i4TFeA7vFS3ckUu1Hr56KRe2w=";
  };

  cargoHash = "sha256-R/l5zMRB/2/a4Yf6toPBBvJ1SvebWsGeumwW9U6b7So=";

  buildFeatures = [ "c-api" ];

  postInstall = ''
    install -Dm644 include/tlottie.h -t "$out/include"
  '';

  meta = with lib; {
    description = "Rust library for drawing Lottie animations";
    homepage = "https://github.com/dkaraush/tlottie";
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
