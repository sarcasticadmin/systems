{ lib, stdenvNoCC, fetchgit }:

stdenvNoCC.mkDerivation rec {
  pname = "sarcasticadmin-dotfiles-unstable";
  version = "09-07-2022";

  src = fetchgit {
    url = "https://github.com/sarcasticadmin/dotfiles";
    rev = "6a8f06f8272f768b8ec089512138f87f94b9e393";
    sha256 = "sha256:1q1ky7bdq5zjd6fdbnff36i8nqwf28h8fds2hcn0wan66rplmiks";
  };

  phases = "unpackPhase patchPhase installPhase";

  installPhase = ''
    mkdir -p $out
    cp -R . $out/
  '';

  meta = with lib; {
    description = "My dotfiles and configs for sanity";
    homepage = "https://github.com/sarcasticadmin/dotfiles";
    license = licenses.mit;
    maintainers =  with maintainers; [ sarcasticadmin ];
    platforms = platforms.unix;
  };
}
