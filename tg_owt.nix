{ lib, stdenv, fetchFromGitHub, fetchpatch
, pkg-config, cmake, ninja, yasm
, libjpeg, openssl, libopus, ffmpeg, alsa-lib, libpulseaudio, protobuf
, openh264, usrsctp, libevent, libvpx
, libX11, libXtst, libXcomposite, libXdamage, libXext, libXrender, libXrandr, libXi
, glib, abseil-cpp, pcre, util-linuxMinimal, libselinux, libsepol, pipewire
, mesa, libepoxy, libglvnd, unstableGitUpdater, darwin
}:

stdenv.mkDerivation {
  pname = "tg_owt";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "desktop-app";
    repo = "tg_owt";
    rev = "dc17143230b5519f3c1a8da0079e00566bd4c5a8";
    sha256 = "sha256-7j7hBIOXEdNJDnDSVUqy234nkTCaeZ9tDAzqvcuaq0o=";
    fetchSubmodules = true;
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ pkg-config cmake ninja yasm ];

  buildInputs = [
    libjpeg
    libopus
    ffmpeg
    protobuf
    openh264 usrsctp
    libevent
    libvpx
    abseil-cpp
    libX11
    libXtst
    libXcomposite
    libXdamage
    libXext
    libXrender
    libXrandr
    libXi
    glib
    pcre
    util-linuxMinimal
    libselinux
    libsepol
    pipewire
    alsa-lib
    libpulseaudio
    mesa
    libepoxy
    libglvnd
  ];

  cmakeFlags = [
    # Building as a shared library isn't officially supported and may break at any time.
    "-DBUILD_SHARED_LIBS=OFF"
  ];

  propagatedBuildInputs = [
    # Required for linking downstream binaries.
    abseil-cpp openh264 usrsctp libevent libvpx openssl
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    license = licenses.bsd3;
    maintainers = with maintainers; [ oxalica ];
  };
}