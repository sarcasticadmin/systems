{ pkgs, config, lib, ... }:

{
  services.autorandr = {
    enable = true;
    defaultTarget = "laptop";
    profiles =
      let
        # get fingerprints: autorandr --fingerprint
        # latop screen
        eDP = "00ffffffffffff0009e5db0700000000011c0104a51f1178027d50a657529f27125054000000010101010101010101010101010101013a3880de703828403020360035ae1000001afb2c80de703828403020360035ae1000001a000000fe00424f452043510a202020202020000000fe004e4531343046484d2d4e36310a0043";
        # office lg screen
        DisplayPort-2 = "00ffffffffffff001e6df15980d90600051b010380502278eaca95a6554ea1260f5054a54b80714f818081c0a9c0b3000101010101017e4800e0a0381f4040403a001e4e31000018023a801871382d40582c45001e4e3100001e000000fc004c4720554c545241574944450a000000fd00384b1e5a18000a20202020202001a502031df14a000403221412051f0113230907078301000065030c001000023a801871382d40582c450056512100001e011d8018711c1620582c250056512100009e011d007251d01e206e28550056512100001e8c0ad08a20e02d10103e9600565121000018000000ff003730354e544c4544363839360a00000000000000000f";
      in
      {
        # monitor config:
        #   laptop connected
        #   external * disconnected
        "laptop" = {
          fingerprint = {
            inherit eDP;
          };
          config = {
            HDMI-A-0.enable = false;
            DisplayPort-0.enable = false;
            DisplayPort-1.enable = false;

            eDP = {
              enable = true;
              primary = true;
              crtc = 0;
              mode = "1920x1080";
              position = "0x0";
              rate = "60.00";
            };
          };
        };

        # monitor config:
        #   external dock DP connected
        #   laptop closed
        "office" = {
          fingerprint = {
            inherit DisplayPort-2;
          };
          config = {
            HDMI-A-0.enable = false;
            # docking station adds to many more DP displays
            DisplayPort-0.enable = false;
            DisplayPort-1.enable = false;
            DisplayPort-3.enable = false;
            DisplayPort-4.enable = false;

            DisplayPort-2 = {
              enable = true;
              primary = true;
              crtc = 1;
              mode = "2560x1080";
              position = "0x0";
              rate = "60.00";
            };
          };
        };
      };
  };

  # Overriding the autorandr systemd service to include --match-edid
  # TODO: figure out what "After" section to enable running at login
  systemd.services.autorandr =
    let
      # Get original config
      cfg = config.services.autorandr;
    in
    {
      serviceConfig = {
        # Leverage --match-edid so that if system uses different output ports its doesnt matter
        # for autorandr detection. This can happen if you unplug/replug into a dock multiple times
        ExecStart = lib.mkForce ''
          ${pkgs.autorandr}/bin/autorandr \
                  --batch \
                  --match-edid \
                  --change \
                  --default ${cfg.defaultTarget}
        '';
        #${lib.strings.optionalString cfg.ignoreLid "--ignore-lid"} # TODO: enable in 22.05 release
      };
    };
}
