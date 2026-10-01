# Desktop apps from the CachyOS install that are packaged in nixpkgs.
# Apps that need system services (Steam, Docker, libvirt) belong in NixOS modules;
# see TODO.md.
{
  flake.homeModules.davidutzDesktop = { pkgs, ... }: {
    home.packages = with pkgs; [
      # chat
      discord
      element-desktop

      # media
      spotify
      mpv
      vlc
      obs-studio
      pinta

      # office and notes
      obsidian
      libreoffice
      evince
      gnome-calculator

      # dev
      vscodium
      meld
      t3code # control surface for coding agents, local or on another machine

      # files and transfer
      localsend

      # games (Steam itself is in system/gaming.nix)
      lutris
      prismlauncher
      wineWow64Packages.stable
      winetricks

      # peripherals (services are in the host config)
      piper
      oversteer
      overskride
    ];

    programs.firefox.enable = true;
  };
}
