{ stdenv }:

stdenv.mkDerivation rec {
  name = "customEdid";

  src = ./1920x1080.bin;

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/lib/firmware/edid
    cp ${src} $out/lib/firmware/edid/1920x1080.bin
  '';

  meta = {
    description = "Custom EDID for forcing 120 Hz refresh rate on Asus G53-SX";
  };
}
