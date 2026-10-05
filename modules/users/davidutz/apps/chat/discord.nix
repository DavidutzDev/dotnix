# Discord, on workspace 10 (the second monitor). Not programs.discord: that module
# makes settings.json read-only, and Discord writes its window state there.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.discord ];

      # WebRTCPipeWireCapturer is what makes screen sharing work on Wayland.
      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("discord --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer --ozone-platform=wayland --enable-gpu-rasterization --enable-zero-copy --ignore-gpu-blocklist"))
        hl.window_rule({ name = "discord", match = { class = "discord" }, workspace = "10" })
      '';
    };
}
