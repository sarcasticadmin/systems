# Isaacs Generic Linker
# A great way of managing your home directory and other files on the system
files: BaseDir:
let
  link = origin: target: "L+ ${target} - - - - ${origin}";
in
{
  systemd.tmpfiles.rules = map ({ origin, target }: link origin "${BaseDir}/${target}") files;
}
