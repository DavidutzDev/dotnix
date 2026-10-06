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
            "tray"
            "network"
            "bluetooth"
            "battery"
            "performance"
            "widgets"
            "notes"
            "emoji"
            "colors"
          ];

          # Notifications, the volume and every other notice show only on the focused
          # monitor; the other one keeps the idle island.
          island.notices = "focus";

          # Each area shows one bubble, the most important; news comes to the front.
          bubbles = {
            stack = true;
            news_ms = 4000;
          };

          module = {
            # Nothing answers logind's lock signal (no hypridle), so run the locker directly.
            power.lock = [ "hyprlock" ];

            # The mixer's sliders and `mochi ipc audio volume` go to 200%; the OSD's bar follows.
            audio.max_volume = 200;

            # Apps with a bubble of their own next to the tray's; `mochi ipc tray list` shows ids.
            tray.pinned = [ "discord" ];

            # A notice once a reading stays over `notice` for `sustain_seconds`, naming the
            # busiest process; a red bubble while it stays over `critical`. 0 turns one off.
            performance = {
              sustain_seconds = 10;
              cpu = { notice = 85; critical = 95; };
              memory = { notice = 85; critical = 95; };
              gpu = { notice = 95; critical = 0; };
              temperature = { notice = 80; critical = 90; };
            };

            # No battery on this desktop: it stays quiet until there is one.
            battery = {
              notices = [ 80 50 20 10 ];
              warning = 50;
              critical = 10;
            };

            # The launcher's providers are built in: apps, `=` calculator (plain math
            # works too), `>` commands, `/` files, web searches (`!w`, `!g`, `!gh`, `!yt`,
            # `!nix`, `!wiki`), `:` emoji and `#` colors.

            # Share a switchable copy, at 60 fps and the screen's own size, by default.
            share = {
              switchable = true;
              framerate = 60;
              resolution = "native";
            };
          };
        };

        # Where the widgets start. `mochi ipc widgets edit` (SUPER + SHIFT + W) moves them;
        # a rebuild only puts this back when it changes, so drags survive. To keep
        # an arrangement, "Copy as Nix" in edit mode and paste it here.
        widgets =
          let
            # Grid cells are 16 px: a 1920 × 1080 screen is 120 × 67 of them.
            widget = id: module: widget: output: anchor: x: y: width: height: settings: {
              inherit id module widget output anchor x y width height settings;
            };
          in
          [
            # DP-3: time and plans on the left, music at the bottom.
            (widget "w1" "widgets" "clock" "DP-3" "top-left" 2 4 16 8 { })
            (widget "w2" "widgets" "calendar" "DP-3" "top-left" 2 13 16 15 { })
            (widget "w3" "notes" "todo" "DP-3" "top-left" 19 4 16 14 { })
            (widget "w4" "notes" "note" "DP-3" "top-left" 19 19 16 9 { })
            (widget "w5" "media" "now-playing" "DP-3" "bottom-left" 2 (-3) 24 8 { })
            # HDMI-A-1: a clock with seconds and the machine's readings.
            (widget "w6" "widgets" "clock" "HDMI-A-1" "top-right" (-2) 4 16 8 { seconds = true; })
            (widget "w7" "performance" "graphs" "HDMI-A-1" "top-right" (-2) 13 18 14 { })
          ];

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
          text.family = "JetBrainsMono Nerd Font";
        };
      };

      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + space", hl.dsp.exec_cmd("mochi ipc launcher toggle"))
        hl.bind("SUPER + C", hl.dsp.exec_cmd("mochi ipc hub toggle"))
        hl.bind("SUPER + N", hl.dsp.exec_cmd("mochi ipc notifications history"))
        hl.bind("SUPER + V", hl.dsp.exec_cmd("mochi ipc clipboard toggle"))
        hl.bind("SUPER + A", hl.dsp.exec_cmd("mochi ipc audio toggle"))
        hl.bind("SUPER + Y", hl.dsp.exec_cmd("mochi ipc tray toggle"))
        hl.bind("SUPER + I", hl.dsp.exec_cmd("mochi ipc hub open performance/page"))
        hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("mochi ipc notifications dnd toggle"))

        -- The emoji grid, and a color picked from the screen.
        hl.bind("SUPER + period", hl.dsp.exec_cmd("mochi ipc emoji toggle"))
        hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("mochi ipc colors pick"))

        -- Closes whatever the island shows. Escape only reaches views that take the
        -- keyboard (launcher, hub, mixer); notices like the volume let it through.
        hl.bind("SUPER + Escape", hl.dsp.exec_cmd("mochi dismiss"))

        -- Arrange the desktop widgets on the focused monitor; Escape or Done stops.
        hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("mochi ipc widgets edit"))

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
