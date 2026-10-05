{ inputs, ... }:
{
  # Required System capabilities otherwise polkit fails
  flake.nixosModules.davidutz.programs.gpu-screen-recorder.enable = true;

  flake.homeModules.davidutzDesktop =
    { config, ... }:
    let
      c =config.davidutz.theme.colors;
    in
    {
      imports = [ inputs.mochi.homeModules.default ];

      programs.mochi = {
        enable = true;

        settings = {
          modules = [
            "idle"
            "osd"
            "workspaces"
            "media"
            "notifications"
            "launcher"
            "hub"
            "power"
            "capture"
            "share"
            "clipboard"
            "audio"
          ];
          # Nothing answers logind's lock signal (no hypridle), so run the locker directly.
          module.power.lock = [ "hyprlock" ];
        };

        theme = {
          colors = {
            background = "#f5${c.crust}";
            surface = "#${c.base}";
            raised = "#${c.surface0}";
            highlight = "#${c.surface1}";
            foreground = "#${c.text}";
            muted = "#${c.overlay1}";
            accent = "#${c.lavender}";
            on_accent = "#${c.crust}";
            danger = "#${c.red}";
            success = "#${c.green}";
          };
          layout.mode = "island";
          text.family ="JetBrainsMono Nerd Font";
        };
      };

      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + space", hl.dsp.exec_cmd("mochi ipc launcher toggle"))
        hl.bind("SUPER + C", hl.dsp.exec_cmd("mochi ipc hub toggle"))
        hl.bind("SUPER + N", hl.dsp.exec_cmd("mochi ipc notifications history"))
        hl.bind("SUPER + V", hl.dsp.exec_cmd("mochi ipc clipboard toggle"))
        hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("mochi ipc notifications dnd toggle"))

        -- Power page of the hub: power profiles, suspend, reboot, shut down.
        hl.bind("XF86Launch1", hl.dsp.exec_cmd("mochi ipc hub open power/power"))
        hl.bind("SUPER + M", hl.dsp.exec_cmd("mochi ipc power logout"))

        -- Print picks a region, window or screen; ALT + Print records, and stops
        -- the recording when pressed again. CTRL takes the whole screen at once.
        hl.bind("Print", hl.dsp.exec_cmd("mochi ipc capture screenshot"))
        hl.bind("ALT + Print", hl.dsp.exec_cmd("mochi ipc capture record"))
        hl.bind("CTRL + Print", hl.dsp.exec_cmd("mochi ipc capture screenshot screen"))
        hl.bind("CTRL + XF86Launch1", hl.dsp.exec_cmd("mochi ipc capture screenshot screen"))
        hl.bind("ALT + XF86Launch1", hl.dsp.exec_cmd("mochi ipc capture screenshot window"))

        hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("mochi ipc media play-pause"), { locked = true })
        hl.bind("XF86AudioPause", hl.dsp.exec_cmd("mochi ipc media play-pause"), { locked = true })
        hl.bind("XF86AudioStop", hl.dsp.exec_cmd("mochi ipc media pause"), { locked = true })
        hl.bind("XF86AudioNext", hl.dsp.exec_cmd("mochi ipc media next"), { locked = true })
        hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("mochi ipc media previous"), { locked = true })
      '';
    };
}
