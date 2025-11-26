{
  pkgs,
  outputDir ? "\\$HOME/music",
  ...
}:

pkgs.abcde.overrideAttrs (previousAttrs: {
 configurePhase = previousAttrs.configurePhase + ''
   cat ${./abcde.conf} >> abcde.conf
   echo -ne "\nOUTPUTDIR="${outputDir}"" >> abcde.conf
 '';
 })
