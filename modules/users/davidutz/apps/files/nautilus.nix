{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nautilus ];

      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("nautilus"))
      '';
    };
}
