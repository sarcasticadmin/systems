{ lib, stdenvNoCC, fetchFromGitHub }:
let
  pname = "sarcasticadmin-dotfiles";
  version = "2025.9.0";
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "sarcasticadmin";
    repo = "dotfiles";
    rev = "${version}";
    hash = "sha256-6z2RDM4cjg1NnXyMz3oWkhKD41oMKOdlOdH8ldOlCGM=";
  };

  phases = "unpackPhase patchPhase installPhase";

  prePatch = ''
    substituteInPlace i3/.i3/config \
          --replace '~/.i3/i3lock.sh' '${placeholder "out"}/i3/.i3/i3lock.sh'
    substituteInPlace gnupg/.gnupg/gpg-agent.conf \
          --replace 'pinentry-program /usr/bin/pinentry-tty' '/usr/bin/pinentry-tty /run/current-system/sw/bin/pinentry-tty'
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
