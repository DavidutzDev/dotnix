# Volume keys and the mixer. Mochi's OSD shows volume and microphone mute as they change.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        pavucontrol
        wireplumber # wpctl
      ];

      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 2.0 @DEFAULT_AUDIO_SINK@ 3%+"), { locked = true, repeating = true })
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-"), { locked = true, repeating = true })
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
        hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
        hl.bind("SUPER + Backspace", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
      '';
    };
}
