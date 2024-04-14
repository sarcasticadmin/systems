{
  networking.wg-quick.interfaces = {
    # the interface arbitrarily.
    wg0 = {
      configFile = "/persist/etc/wireguard/ec-rmsgw.conf";
    };
  };
}
