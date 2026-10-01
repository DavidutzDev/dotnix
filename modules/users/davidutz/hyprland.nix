# Hyprland config from github:DavidutzDev/dotfiles (pinned in flake.lock).
# The host must import nixosModules.hyprland (modules/system/hyprland.nix).
#
# Odyssey writes odyssey.lua, hyprlock.conf, hypridle.conf and scheme/current.lua into
# ~/.config/hypr at runtime. Home-manager links individual files, not the directory,
# so those four stay ordinary writable files as long as nothing below manages them.
{ inputs, ... }: {
  flake.homeModules.davidutzDesktop = { lib, pkgs, ... }:
    let
      hypr = "${inputs.dotfiles}/hyprland/.config/hypr";

      # Lua module names, in the layout Hyprland's require() expects.
      luaModules = [
        "core.init"
        "core.apps"
        "core.autostart"
        "core.bindings"
        "core.ecosystem"
        "core.environment"
        "core.monitors"
        "config.apps"
        "config.autostart"
        "config.bindings"
        "config.env"
        "config.input"
        "config.layouts"
        "config.looknfeel"
        "config.misc"
        "config.monitors"
        "themes.catppuccin-mocha"
      ];
    in
    {
      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";
        # Use the packages from the NixOS module so both sides run the same build.
        package = null;
        portalPackage = null;
        # UWSM starts the systemd session, so home-manager's own target is not needed.
        systemd.enable = false;

        # autoLoad = false: hyprland.lua below requires them in the order that matters.
        extraLuaFiles = lib.genAttrs luaModules (name: {
          content = "${hypr}/${lib.replaceStrings [ "." ] [ "/" ] name}.lua";
          autoLoad = false;
        });

        # Same sequence as hyprland.lua in the dotfiles repo. odyssey.lua is written by
        # Odyssey's installer, so a fresh machine without it must still start.
        extraConfig = ''
          require("core")

          require("config.autostart")
          require("config.env")
          require("config.apps")
          require("config.monitors")
          require("config.bindings")
          require("config.looknfeel")
          require("config.layouts")
          require("config.misc")
          require("config.input")

          pcall(require, "odyssey")
        '';
      };

      # Everything the Lua config calls by name (config/apps.lua, core/ecosystem.lua,
      # config/autostart.lua).
      home.packages = with pkgs; [
        ghostty
        nautilus
        hyprshot
        satty
        hyprpicker
        cliphist
        wl-clipboard
        wl-clip-persist
        awww
        playerctl
        brightnessctl
        pavucontrol
        quickshell # Odyssey runs on Quickshell
        matugen
      ];

      services.hyprpolkitagent.enable = true;

      xdg.configFile."ghostty".source = "${inputs.dotfiles}/ghostty/.config/ghostty";

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

      qt = {
        enable = true;
        platformTheme.name = "adwaita";
        style.name = "adwaita-dark";
      };
    };
}
