# desktop-btw: the CachyOS machine, described for NixOS. Still named test-vm until
# the rename.
{ self, ... }: {
  flake.nixosModules.desktop-btwConfiguration =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = with self.nixosModules; [
        desktop-btwHardware
        desktop-btwDisko
        impermanence
        nix
        audio
        network
        performance
        virtualisation
        gaming
        desktop
        hyprland
        davidutz
      ];

      networking.hostName = "desktop-btw";
      time.timeZone = "Europe/Brussels";
      i18n.defaultLocale = "en_US.UTF-8";
      services.xserver.xkb.layout = "gb";
      console.keyMap = "uk";

      # --- boot ---

      # systemd-boot installs next to CachyOS's Limine on the same ESP, so both stay
      # bootable during the move. Pick CachyOS from the firmware boot menu.
      boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      boot.loader.efi.canTouchEfiVariables = true;

      boot.initrd.systemd.enable = true;
      boot.plymouth.enable = true;
      boot.kernelParams = [
        "quiet" # plymouth adds "splash"
        # single-GPU passthrough, see below
        "iommu=pt"
        "pcie_acs_override=downstream,multifunction"
      ];

      # Closest nixpkgs kernel to linux-cachyos, and it carries the ACS override
      # patch that pcie_acs_override below needs.
      boot.kernelPackages = pkgs.linuxPackages_zen;

      # --- GPU: GTX 1060 (Pascal) ---

      # Pascal needs the proprietary module; the 580 branch is its last one
      # (CachyOS: nvidia-580xx-dkms).
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = [ pkgs.nvidia-vaapi-driver ]; # CachyOS: libva-nvidia-driver
      };
      hardware.nvidia = {
        open = false;
        modesetting.enable = true;
        powerManagement.enable = true; # nvidia-suspend/resume/hibernate
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      };

      # --- single-GPU passthrough (~/win-vm) ---

      # The scripts in ~/win-vm bind the GPU to vfio-pci at VM start.
      boot.extraModprobeConfig = "options kvm ignore_msrs=1";

      # --- firewall ---

      networking.firewall.allowedTCPPorts = [ 25567 ];

      # --- peripherals ---

      hardware.bluetooth.enable = true;
      services.ratbagd.enable = true; # Piper
      services.udev.packages = [ pkgs.oversteer ]; # wheel permissions

      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };

      # users.mutableUsers is off (impermanence), so the password comes from a file on
      # the persistent subvolume. Create it with `mkpasswd` during install (INSTALL.md).
      users.users.davidutz.hashedPasswordFile = "/persist/passwords/davidutz";

      # Your home on this machine, through the `hm` alias from users/davidutz/account.nix:
      # the desktop, the coding agents, and a host-only package.
      hm.imports = with self.homeModules; [
        davidutzDesktop
        davidutzAgents
      ];
      hm.home.packages = with pkgs; [
        nvtopPackages.nvidia
      ];

      # Main monitor on the right; the left one holds workspace 10 (Discord, Spotify).
      hm.wayland.windowManager.hyprland.extraConfig = ''
        hl.monitor({ output = "DP-3", mode = "1920x1080@165", position = "1920x0", scale = 1 })
        hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1 })

        for ws = 1, 5 do
          hl.workspace_rule({ workspace = tostring(ws), monitor = "DP-3", default = true })
        end
        hl.workspace_rule({ workspace = "10", monitor = "HDMI-A-1", default = true, layout = "scrolling" })

        hl.env("GBM_BACKEND", "nvidia-drm")
        hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
      '';

      system.stateVersion = "26.05";
    };
}
