{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "sarcasticadmin-dotfiles";
  version = "2024.9.0";

  src = fetchFromGitHub {
    owner = "sarcasticadmin";
    repo = "dotfiles";
    rev = "${version}";
    hash = "sha256-V8yzDrRZE6vRMLTB/LnUQ8Rc/M3pysW6c98qkQNBdnk=";
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
