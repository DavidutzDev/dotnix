# Screen and keyboard backlight keys.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.brightnessctl ];

      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
        hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("brightnessctl -d '*::kbd_backlight' set +1"), { repeating = true })
        hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d '*::kbd_backlight' set 1-"), { repeating = true })
      '';
    };
}
