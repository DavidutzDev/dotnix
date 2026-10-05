# Gaps, borders, rounding, blur, layouts and animations.
{
  flake.homeModules.davidutzDesktop =
    { config, ... }:
    let
      c = config.davidutz.theme.colors;
    in
    {
      wayland.windowManager.hyprland.extraConfig = ''
        hl.config({
          general = {
            gaps_in = 5,
            gaps_out = 20,
            border_size = 2,
            col = {
              active_border = { colors = { "rgb(${c.lavender})", "rgb(${c.blue})" }, angle = 45 },
              inactive_border = "rgb(${c.base})",
            },
            resize_on_border = false,
            -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ first.
            allow_tearing = false,
            layout = "dwindle",
          },

          decoration = {
            rounding = 15,
            rounding_power = 2,
            active_opacity = 0.9,
            inactive_opacity = 0.8,
            shadow = {
              enabled = true,
              range = 15,
              render_power = 3,
              color = 0xee121212,
            },
            blur = {
              enabled = true,
              size = 20,
              passes = 3,
              vibrancy = 0.1696,
            },
          },

          animations = { enabled = true },

          dwindle = { preserve_split = true },
          master = { new_status = "master" },
          scrolling = { fullscreen_on_one_column = true },

          misc = {
            force_default_wallpaper = -1,
            disable_hyprland_logo = false,
            initial_workspace_tracking = 0,
          },
        })

        -- Hyprland's default curves, with every animation at half its default
        -- duration (speed is in tenths of a second). See
        -- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
        hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
        hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
        hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
        hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
        hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
        hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

        hl.animation({ leaf = "global", enabled = true, speed = 5, bezier = "default" })
        hl.animation({ leaf = "border", enabled = true, speed = 2.7, bezier = "easeOutQuint" })
        hl.animation({ leaf = "windows", enabled = true, speed = 2.4, spring = "easy" })
        hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.05, spring = "easy", style = "popin 87%" })
        hl.animation({ leaf = "windowsOut", enabled = true, speed = 0.75, bezier = "linear", style = "popin 87%" })
        hl.animation({ leaf = "fadeIn", enabled = true, speed = 0.87, bezier = "almostLinear" })
        hl.animation({ leaf = "fadeOut", enabled = true, speed = 0.73, bezier = "almostLinear" })
        hl.animation({ leaf = "fade", enabled = true, speed = 1.5, bezier = "quick" })
        hl.animation({ leaf = "layers", enabled = true, speed = 1.9, bezier = "easeOutQuint" })
        hl.animation({ leaf = "layersIn", enabled = true, speed = 2, bezier = "easeOutQuint", style = "fade" })
        hl.animation({ leaf = "layersOut", enabled = true, speed = 0.75, bezier = "linear", style = "fade" })
        hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 0.9, bezier = "almostLinear" })
        hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 0.7, bezier = "almostLinear" })
        hl.animation({ leaf = "workspaces", enabled = true, speed = 0.97, bezier = "almostLinear", style = "fade" })
        hl.animation({ leaf = "workspacesIn", enabled = true, speed = 0.6, bezier = "almostLinear", style = "fade" })
        hl.animation({ leaf = "workspacesOut", enabled = true, speed = 0.97, bezier = "almostLinear", style = "fade" })
        hl.animation({ leaf = "zoomFactor", enabled = true, speed = 3.5, bezier = "quick" })
      '';
    };
}
