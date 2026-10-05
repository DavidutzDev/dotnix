# Keyboard, mouse, touchpad.
{
  flake.homeModules.davidutzDesktop = {
    wayland.windowManager.hyprland.extraConfig = ''
      hl.config({
        input = {
          kb_layout = "gb",
          kb_options = "compose:ralt",
          follow_mouse = 1,
          sensitivity = 0,
          touchpad = { natural_scroll = false },
        },
        cursor = {
          no_hardware_cursors = false,
          use_cpu_buffer = true,
        },
      })

      hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
    '';
  };
}
