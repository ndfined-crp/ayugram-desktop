{ pkgs ? import <nixpkgs> { system = builtins.currentSystem; }
, lib ? pkgs.lib
, stdenv ? pkgs.stdenv
, fetchFromGitHub ? pkgs.fetchFromGitHub
, fetchpatch ? pkgs.fetchpatch
, pkg-config ? pkgs.pkg-config
, cmake ? pkgs.cmake
, ninja ? pkgs.ninja
, yasm ? pkgs.yasm
, libjpeg ? pkgs.libjpeg
, openssl ? pkgs.openssl
, libopus ? pkgs.libopus
, ffmpeg ? pkgs.ffmpeg
, alsa-lib ? pkgs.alsa-lib
, libpulseaudio ? pkgs.libpulseaudio
, protobuf ? pkgs.protobuf
, openh264 ? pkgs.openh264
, usrsctp ? pkgs.usrsctp
, libevent ? pkgs.libevent
, libvpx ? pkgs.libvpx
, libX11 ? pkgs.xorg.libX11
, libXtst ? pkgs.xorg.libXtst
, libXcomposite ? pkgs.xorg.libXcomposite
, libXdamage ? pkgs.xorg.libXdamage
, libXext ? pkgs.xorg.libXext
, libXrender ? pkgs.xorg.libXrender
, libXrandr ? pkgs.xorg.libXrandr
, libXi ? pkgs.xorg.libXi
, glib ? pkgs.glib
, abseil-cpp ? pkgs.abseil-cpp
, pcre ? pkgs.pcre
, util-linuxMinimal ? pkgs.util-linuxMinimal
, libselinux ? pkgs.libselinux
, libsepol ? pkgs.libsepol
, pipewire ? pkgs.pipewire
, mesa ? pkgs.mesa
, libepoxy ? pkgs.libepoxy
, libglvnd ? pkgs.libglvnd
, unstableGitUpdater ? pkgs.unstableGitUpdater
, darwin ? pkgs.darwin
, python3 ? pkgs.python3
}:

stdenv.mkDerivation {
  pname = "tg_owt";
  version = "unstable-2024-08-04";

  src = fetchFromGitHub {
    owner = "desktop-app";
    repo = "tg_owt";
    rev = "dc17143230b5519f3c1a8da0079e00566bd4c5a8";
    sha256 = "sha256-7j7hBIOXEdNJDnDSVUqy234nkTCaeZ9tDAzqvcuaq0o";
    fetchSubmodules = true;
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ pkg-config cmake ninja yasm ];

  buildInputs = [
    libjpeg libopus ffmpeg protobuf openh264 usrsctp libevent libvpx abseil-cpp
    libX11 libXtst libXcomposite libXdamage libXext libXrender libXrandr libXi
    glib pcre util-linuxMinimal libselinux libsepol pipewire alsa-lib libpulseaudio
    mesa libepoxy libglvnd python3
  ];

  patches = [
    # GCC 12 Fix
    (fetchpatch {
      url = "https://github.com/desktop-app/tg_owt/pull/101/commits/86d2bcd7afb8706663d29e30f65863de5a626142.patch";
      hash = "sha256-iWS0mB8R0vqPU/0qf6Ax54UCAKYDVCPac2mi/VHbFm0=";
    })
    # additional fix for GCC 12 + musl
    (fetchpatch {
      url = "https://git.alpinelinux.org/aports/plain/community/tg_owt/gcc12.patch?id=8120df03fa3b6db5b8ff92c7a52b680290ad6e20";
      hash = "sha256-ikgxUH1e7pz0n0pKUemrPXXa4UkECX+w467M9gU68zs=";
    })
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