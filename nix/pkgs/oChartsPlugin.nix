{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  # https://github.com/bdbcat/o-charts_pi.git
  pname = "o-charts_pi";
  version = "1.0.34.0";

  src = pkgs.fetchFromGitHub {
    owner = "bdbcat";
    repo = "o-charts_pi";
    rev = "${version}";
    hash = "sha256-UP6alDMglvp4tGs1eGMx9uFx5IMDm43NBlTL7em0a4I=";
  };
  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    gettext
    xorg.libX11.dev
  ] ++ lib.optionals stdenv.isLinux [
    lsb-release
  ];
  buildInputs = with pkgs; [
    wxGTK31 # Instead of wxGTK32 due to deprecation errors - maybe try compat in 32 later?
    tinyxml
    zlib
    curl
    libGLU
    libGL
  ];
  #cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];
  #SEARCH_LIB = "${pkgs.libGLU.out}/lib ${pkgs.libGL.out}/lib";
};
