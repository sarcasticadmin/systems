{
  # Enables wireless support via wpa_supplicant
  networking.wireless.enable = true;
  # Option is misleading but we dont want it
  networking.wireless.userControlled.enable = false;
  # Allow configuring networks "imperatively"
  networking.wireless.allowAuxiliaryImperativeNetworks = true;

  environment.etc."wpa_supplicant.conf" = {
    source = "/persist/etc/wpa_supplicant.conf";
    mode = "symlink";
  };
}
