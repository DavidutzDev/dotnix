# One colour palette for everything (Catppuccin Mocha), plus GTK and Qt.
#
# Starship, Hyprland, ghostty, hyprlock and Mochi read their colours from
# `davidutz.theme.colors`, so switching the palette here switches all of them.
# The palette is in the base profile, so the terminal setup has it without a desktop.
{
  flake.homeModules.davidutz =
    { lib, ... }:
    {
      options.davidutz.theme.colors = lib.mkOption {
        type = with lib.types; attrsOf str;
        description = "Palette as hex RGB without `#`, keyed by Catppuccin colour name.";
        default = {
          rosewater = "f5e0dc";
          flamingo = "f2cdcd";
          pink = "f5c2e7";
          mauve = "cba6f7";
          red = "f38ba8";
          maroon = "eba0ac";
          peach = "fab387";
          yellow = "f9e2af";
          green = "a6e3a1";
          teal = "94e2d5";
          sky = "89dceb";
          sapphire = "74c7ec";
          blue = "89b4fa";
          lavender = "b4befe";
          text = "cdd6f4";
          subtext1 = "bac2de";
          subtext0 = "a6adc8";
          overlay2 = "9399b2";
          overlay1 = "7f849c";
          overlay0 = "6c7086";
          surface2 = "585b70";
          surface1 = "45475a";
          surface0 = "313244";
          base = "1e1e2e";
          mantle = "181825";
          crust = "11111b";
        };
      };
    };

  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      # colorScheme sets org.gnome.desktop.interface color-scheme = prefer-dark, which
      # the GTK portal hands to libadwaita, Firefox/Zen, Chromium and Electron apps.
      gtk = {
        enable = true;
        colorScheme = "dark";
        # GTK3 apps ignore color-scheme and need a dark theme. GTK4 follows
        # color-scheme on its own, so it keeps libadwaita's stock look.
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        gtk4.theme = null;
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
      };

      # GTK settings GUI.
      home.packages = [ pkgs.nwg-look ];
      wayland.windowManager.hyprland.extraConfig = ''
        hl.bind("SUPER + comma", hl.dsp.exec_cmd("nwg-look"))
      '';

      qt = {
        enable = true;
        platformTheme.name = "adwaita";
        style.name = "adwaita-dark";
      };
    };
}
