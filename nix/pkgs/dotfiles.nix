{ lib, stdenvNoCC, fetchFromGitHub }:
let
  pname = "sarcasticadmin-dotfiles";
  version = "2026.4.0";
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "sarcasticadmin";
    repo = "dotfiles";
    rev = "${version}";
    hash = "sha256-7Kc8lucW5do6nBLciTbun8f5RiWsyiSxfQD5HRF00T0=";
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
