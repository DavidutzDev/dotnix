# Network services enabled on CachyOS: NetworkManager, systemd-resolved, avahi (mDNS),
# sshd, Tailscale. home-sweet-home: system/network, system/firewall, system/tailscale.
{
  flake.nixosModules.network = { pkgs, ... }: {
    networking.networkmanager = {
      enable = true;
      plugins = [ pkgs.networkmanager-openvpn ];
    };
    services.resolved.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    services.openssh = {
      enable = true; # also opens port 22
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    services.tailscale.enable = true;

    # CachyOS uses ufw; NixOS's firewall is on by default. Services open their own
    # ports through openFirewall options, and the tailnet is trusted.
    networking.firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
    };

    environment.systemPackages = with pkgs; [ wireguard-tools ];
  };
}
