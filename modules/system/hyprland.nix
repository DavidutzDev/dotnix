# Machine side of the Hyprland desktop: compositor, session, lock screen PAM,
# portals, keyring, fonts. Import it on hosts that have a screen.
# The user's Hyprland config is in modules/users/davidutz/hyprland.nix.
{
  flake.nixosModules.hyprland = { pkgs, ... }: {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
    programs.hyprlock.enable = true; # also installs the PAM service hyprlock needs
    # Odyssey's idlectl.sh adds a drop-in to this unit that points ExecStart at
    # `odyssey hypridle`, so the NixOS-provided unit is the one it customises.
    services.hypridle.enable = true;

    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    services.gnome.gnome-keyring.enable = true;
    security.polkit.enable = true;

    # Electron and Chromium apps pick Wayland on their own with this set.
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };
}
