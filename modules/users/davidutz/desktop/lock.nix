# Lock screen (SUPER + L): the blurred desktop, a clock and the password field.
{
  flake.homeModules.davidutzDesktop =
    { config, ... }:
    let
      c = config.davidutz.theme.colors;
      font = "JetBrainsMono Nerd Font";
    in
    {
      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))
      '';

      programs.hyprlock = {
        enable = true;
        # nixosModules.hyprland installs hyprlock together with its PAM service.
        package = null;

        settings = {
          general.hide_cursor = true;

          background = [
            {
              path = "screenshot";
              blur_passes = 3;
              blur_size = 8;
              brightness = 0.8;
            }
          ];

          label = [
            {
              text = ''cmd[update:1000] date +"%H:%M"'';
              color = "rgb(${c.text})";
              font_size = 90;
              font_family = font;
              position = "0, 200";
              halign = "center";
              valign = "center";
            }
            {
              text = ''cmd[update:60000] date +"%A %d %B"'';
              color = "rgb(${c.subtext1})";
              font_size = 24;
              font_family = font;
              position = "0, 100";
              halign = "center";
              valign = "center";
            }
          ];

          input-field = [
            {
              size = "300, 56";
              outline_thickness = 2;
              outer_color = "rgb(${c.lavender})";
              inner_color = "rgb(${c.surface0})";
              font_color = "rgb(${c.text})";
              check_color = "rgb(${c.yellow})";
              fail_color = "rgb(${c.red})";
              font_family = font;
              placeholder_text = "Password";
              fade_on_empty = false;
              position = "0, -40";
              halign = "center";
              valign = "center";
            }
          ];
        };
      };
    };
}
