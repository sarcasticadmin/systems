{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./disko.nix
    ];

  # need to be 6.18 to avoid https://copy.fail/
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  boot = {
    # For now copying from
    # https://github.com/NixOS/nixos-hardware/blob/master/pcengines/apu/default.nix
    # Initially for booting had to follow this: https://gist.github.com/tomfitzhenry/35389b0907d9c9172e5d790ca9e0d0dc
    kernelParams = [ "console=ttyS0,115200n8" ];
    loader.grub = {
      enable = true;
      extraConfig = "
        serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
        terminal_input serial
        terminal_output serial
      ";
    };

    kernel.sysctl = {
      # if you use ipv4, this is all you need
      # especially for masq NAT
      "net.ipv4.conf.all.forwarding" = true;
    };
  };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  security.sudo.wheelNeedsPassword = false;

  networking = {
    hostId = "217d26c8";
    hostName = "router"; # Define your hostname.
    domain = "local";

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    vlans = {
      vlan44 = { id=44; interface="enp2s0"; };
      vlan45 = { id=45; interface="enp2s0"; };
      vlan46 = { id=46; interface="enp2s0"; };
      vlan47 = { id=47; interface="enp2s0"; };
    };

    interfaces = {
      # Leaving open for config
      enp1s0 = {
       useDHCP = true;
      };
      # The trunk
      #enp2s0 = {
      # useDHCP = false;
      #};
      vlan44 = {
        ipv4.addresses = [ {
          address = "192.168.44.1";
          prefixLength = 24;
        }];
      };
      vlan45 = {
        ipv4.addresses = [ {
          address = "192.168.45.1";
          prefixLength = 24;
        }];
      };
      vlan46 = {
        ipv4.addresses = [ {
          address = "192.168.46.1";
          prefixLength = 24;
        }];
      };
      vlan47 = {
        ipv4.addresses = [ {
          address = "192.168.47.1";
          prefixLength = 24;
        }];
      };
      # Modem
      enp3s0 = {
       useDHCP = true;
      };
    };

    # Well be using NFtables so lets turn off these IPtables settings for nat and firewall
    nat = {
      enable = false;
    };

    firewall = {
      enable = false;
    };

    # Alternatively going with nftables
    # ruleset modelled after: https://wiki.nftables.org/wiki-nftables/index.php/Classic_perimetral_firewall_example
    # https://francis.begyn.be/blog/nixos-home-router
    # http://www.netfilter.org/documentation/index.html
    nftables = {
      enable = true;
      # Note: You can only jump to regular chains.
      # Note: No hook keyword is included when adding a regular chain. Because it is not attached to a Netfilter hook, by itself a regular chain does not see any traffic.
      ruleset = ''
        flush ruleset

        define nic_inet = enp3s0
        define nic_lan = vlan44
        define nic_wifi = vlan45
        define nic_wifi_guest = vlan46
        define nic_lab = vlan47

        table inet filter {
          chain global {
                  ct state established,related accept
                  ct state invalid drop
                  # DHCP Server
                  iifname != $nic_inet udp dport 67 accept
                  # pixiecore
                  iifname != $nic_inet udp dport 68 accept
                  iifname != $nic_inet udp dport 69 accept
                  iifname != $nic_inet tcp dport 80 accept
                  iifname != $nic_inet udp dport 4011 accept
                  # DNS Server
                  iifname != $nic_inet udp dport 53 accept
                  iifname $nic_lan tcp dport 9100 accept
                  iifname $nic_lan tcp dport 9090 accept
                  # Cups/Printing
		  iifname != $nic_inet tcp dport { 515, 631, 9100, 9101, 9102 } accept
          }

          chain lab_in {
            # your rules for traffic to your lab servers
          }

          chain lab_out {
            # your rules for traffic from the lab to internet
            accept
          }

          chain lan_in {
            # your rules for traffic to your LAN nodes
            # all ssh from anywhere into lab vlan
	    tcp dport { 22 } accept
	    tcp dport { 80 } accept
	    tcp dport { 443 } accept
          }

          chain lan_out {
            # your rules for traffic from the LAN to the internet
            accept
          }

          chain wifi_in {
            # your rules for traffic to your lab servers
          }

          chain wifi_out {
            # your rules for traffic from the lab to internet
            accept
          }

          chain wifi_guest_in {
            # your rules for traffic to your lab servers
          }

          chain wifi_guest_out {
            # your rules for traffic from the lab to internet
            accept
          }

          chain forward {
            type filter hook forward priority 0; policy drop;
            jump global
            oifname vmap {
              $nic_lab : jump lab_in ,
              $nic_wifi : jump wifi_in ,
              $nic_wifi_guest : jump wifi_guest_in ,
              $nic_lan : jump lan_in
            }
            oifname $nic_inet iifname vmap {
              $nic_lab : jump lab_out ,
              $nic_wifi : jump wifi_out ,
              $nic_wifi_guest : jump wifi_guest_out ,
              $nic_lan : jump lan_out
            }
          }

          chain input {
            type filter hook input priority 0 ; policy drop;
            jump global
            # your rules for traffic to the firewall here
            # Allow ssh for non inet interfaces to the firewall
	    iifname != $nic_inet tcp dport 22 accept
            # Allow pinging to firewall
            ip protocol icmp accept
            ip6 nexthdr icmpv6 accept
          }

          chain output {
           type filter hook output priority 0 ; policy accept;
           # your rules for traffic originated from the firewall itself here
           # for now allow anything outbound
          }

        }

        table ip nat {
          chain prerouting {
            type nat hook prerouting priority 0
          }

          chain postrouting {
            # Higher priority for NAT might be important
            type nat hook postrouting priority 100

            oifname $nic_inet masquerade
          }
        }
      '';
    };
  };

  services.pixiecore = {
    enable = true;
    openFirewall = true;
    dhcpNoBind = true;
    mode = "boot";
    kernel = "${inputs.self.nixosConfigurations.simpleNetboot.config.system.build.kernel}/bzImage";
    initrd = "${inputs.self.nixosConfigurations.simpleNetboot.config.system.build.netbootRamdisk}/initrd";
    cmdLine = "init=${inputs.self.nixosConfigurations.simpleNetboot.config.system.build.toplevel}/init loglevel=4";
    debug = true;
  };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    dnsmasq
  ];

  sarcasticadmin = {
    base.enable = true;
    users.rherna.enable = true;
    nix = {
      inherit (inputs) nixpkgs nixpkgs-unstable;
      enable = true;
    };
  };

  # Enable the OpenSSH daemon.
  services = {
    openssh = {
      enable = true;
      # Even though no port specified in firewall
      # we still need to set this option due to historical
      # reasons if using iptables.
      # https://github.com/NixOS/nixpkgs/issues/19504#issuecomment-271097412
      # https://github.com/NixOS/nixpkgs/blob/ba1fa0c60406a21b933f5cb1625e80ac0da84f50/nixos/modules/services/networking/ssh/sshd.nix#L161
      openFirewall = false;
    };

    # TODO: Fix: trace: warning: The option `services.dnsmasq.servers' defined in `/nix/store/qpl0hvjgbpsdznaf23n6idrq34jqz11q-source/nix/machines/router1/configuration.nix' has been renamed to `services.dnsmasq.settings.server'.
    # TODO: Fix: trace: warning: Text based config is deprecated, dnsmasq now supports `services.dnsmasq.settings` for an attribute-set based config
    dnsmasq = {
      enable = true;
      settings = {
        server = [ "8.8.8.8" "8.8.4.4" ];
        domain = "local";
        interface = ["vlan44" "vlan45" "vlan46" "vlan47"];
        bind-interfaces = true;
        dhcp-range = ["vlan44,192.168.44.100,192.168.44.190,12h" "vlan45,192.168.45.100,192.168.45.190,12h" "vlan46,192.168.46.100,192.168.46.190,12h" "vlan47,192.168.47.100,192.168.47.190,12h"];
      };
    };
  };

  system.stateVersion = "23.05";
}
