{
  flake.homeModules.davidutzDesktop = {
    programs.vscodium.enable = true;

    wayland.windowManager.hyprland.extraConfig = ''
      hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("codium"))
    '';
  };
}
