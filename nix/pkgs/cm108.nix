{ lib
,  fetchFromGitHub
, pkg-config
, systemd
, stdenv
}:
stdenv.mkDerivation {
  pname   = "cm108";
  version = "unstable";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ systemd ];

  src = fetchFromGitHub {
    owner = "twilly";
    repo = "cm108";
    rev = "ca260ba20bc4966816db05b42d47be587c80e219";
    sha256 = "sha256-bBGf8YSELPtK1LOM0rto6SMoO98cZNoWNUtBKyDcAHc=";
  };

  installPhase = ''
    mkdir -p $out/bin
    install -Dm 755 cm108 $out/bin/mycm108
  '';

  meta = with lib; {
    description = "CM108/119 GPIO CLI Fork";
    homepage = "https://github.com/twilly/cm108";
    maintainers = with maintainers; [ sarcasticadmin ];
    platforms = platforms.linux;
  };
}
