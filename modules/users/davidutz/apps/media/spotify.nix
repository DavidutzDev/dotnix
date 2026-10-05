# Spotify, on workspace 10 (the second monitor).
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.spotify ];

      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("spotify"))
        hl.window_rule({ name = "spotify", match = { class = "Spotify" }, workspace = "10" })
      '';
    };
}
