{ stdenv , lib , fetchurl , appimageTools , makeWrapper , electron_11 }:

let
  electron = electron_11;
in
stdenv.mkDerivation rec {
  pname = "super-productivity";
  version = "7.5.1";

  src = fetchurl {
    url = "https://github.com/johannesjo/super-productivity/releases/download/v${version}/superProductivity-${version}.AppImage";
    sha256 = "sha256-ezJN/t0iNk0haMLPioEQSNXU4ugVeJe44GNVGd+cOF4=";
    name = "${pname}-${version}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    name = "${pname}-${version}";
    inherit src;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/${pname} $out/share/applications

    cp -a ${appimageContents}/{locales,resources} $out/share/${pname}
    cp -a ${appimageContents}/superproductivity.desktop $out/share/applications/${pname}.desktop
    cp -a ${appimageContents}/usr/share/icons $out/share

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/${pname}/resources/app.asar \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc ]}"
  '';

  meta = with lib; {
    description = "To Do List / Time Tracker with Jira Integration";
    homepage = "https://super-productivity.com";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ offline ];
  };
}
