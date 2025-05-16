{ lib, stdenv, flac, pkg-config, fetchFromGitHub }:
let
  pname = "accrip";
  version = "0.1";
in
stdenv.mkDerivation {
  inherit pname version;

  buildInputs = [ flac ];

  nativeBuildInputs = [ pkg-config ];

  src = fetchFromGitHub {
    owner = "sarcasticadmin";
    repo = "accrip";
    rev = "129ceb215fc994133c20f3126f7e563219425a70";
    hash = "sha256-YDJPR3ONL1/66ZetFUY6AUJvSS6CSunZDRc3/Vvflng=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp accuraterip-crcgen $out/bin/accrip
  '';

  meta = with lib; {
    description = "Omy's ARFlac.pl/ARCue.pl C port";
    homepage = "https://github.com/sarcasticadmin/accrip";
    maintainers = with maintainers; [ sarcasticadmin ];
    platforms = platforms.unix;
  };
}
