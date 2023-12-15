{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "sarcasticadmin-dotfiles";
  version = "2023.12.0";

  src = fetchFromGitHub {
    owner = "sarcasticadmin";
    repo = "dotfiles";
    rev = "${version}";
    hash = "sha256-0C4fhZ6KkrjotGyDr8m9BJLW0V46F65rXZsS87jOw1Q=";
  };

  phases = "unpackPhase patchPhase installPhase";

  prePatch = ''
    substituteInPlace i3/.i3/config \
          --replace '~/.i3/i3lock.sh' '${placeholder "out"}/i3/.i3/i3lock.sh'
    patchShebangs .
  '';
  installPhase = ''
    mkdir -p $out
    cp -R . $out/
  '';

  meta = with lib; {
    description = "My dotfiles and configs for sanity";
    homepage = "https://github.com/sarcasticadmin/dotfiles";
    license = licenses.mit;
    maintainers = with maintainers; [ sarcasticadmin ];
    platforms = platforms.unix;
  };
}
