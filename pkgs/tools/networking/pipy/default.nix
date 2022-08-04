{ lib
, pkgs ? import <nixpkgs> { }
, stdenv
, fetchurl
, withGUI ? true
}:

let
  cmakeBool = g: if g then "ON" else "OFF";
in
stdenv.mkDerivation rec {
  name = "pipy-${version}";
  version = "0.50.0-37";

  ci_commit_sha = "5c115a842c4e98559fd83a6271be2d3ba79ef914";
  ci_commit_data = "Tue, 26 Jul 2022 19:08:51 +0800";

  src = fetchurl {
    url = "https://github.com/flomesh-io/pipy/archive/refs/tags/${version}.tar.gz";
    sha256 = "sha256-wDrBfPhwyMCK4QPkG7rcTUU5i2EfuXey5iW/X5ocfB4=";
  };

  buildInputs = with pkgs; [
    cmake
    perl
  ] ++ lib.optional withGUI [ nodejs ];

  cmakeFlags = [
    "-DPIPY_GUI=${cmakeBool withGUI}"
    "-DPIPY_TUTORIAL=${cmakeBool withGUI}"
    "-DCMAKE_BUILD_TYPE=Release"
  ] ++ lib.optional pkgs.stdenvNoCC.isLinux [ "-DPIPY_STATIC=ON" ];

  preConfigure = ''
    export CC=${pkgs.clang}/bin/clang
    export CXX=${pkgs.clang}/bin/clang++

    export CI_COMMIT_TAG="${version}"
    export CI_COMMIT_SHA=${ci_commit_sha}
    export CI_COMMIT_DATE="${ci_commit_data}"

    if [ ${cmakeBool withGUI} = "ON" ]
    then
      HOME=. npm install
      HOME=. npm run build
    fi
  '';

  postInstall = ''
    cd ../
    mkdir -p $out/bin
    mv bin/pipy $out/bin/pipy
  '';

  meta = with lib; {
    description = "Pipy is a programmable network proxy for the cloud, edge and IoT";
    longDescription = ''
      Pipy is a programmable proxy for the cloud, edge and IoT. Written in C++, Pipy is extremely lightweight and fast. It's also programmable by using PipyJS, a tailored version of the standard JavaScript language.
    '';
    homepage = "https://flomesh.io";
    license = {
      fullName = "MIT License Modern Variant";
      shortName = "MIT-Modern-Variant";
      url = "https://spdx.org/licenses/MIT-Modern-Variant.html";
    };
    maintainers = [ maintainers.ethinx ];
    platforms = platforms.all;
  };
}
