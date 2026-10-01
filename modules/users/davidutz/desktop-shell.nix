# Waybar, Walker (with Elephant) and swaync: the desktop shell from before Odyssey,
# restored from ~/dotfiles history (commit 698af71^) into desktop-shell/.
#
# Odyssey isn't packaged for Nix yet. Until it is installed, this gives the session a
# bar, launcher, clipboard history, power menu and notifications:
#
#   - The four services only start when ~/.config/hypr/odyssey.lua is missing. Odyssey's
#     installer writes that file, so installing Odyssey switches them off from the
#     next login on.
#   - config/bindings.lua (shared with CachyOS) sends its shell keys to
#     `odyssey ipc <command>`. The `odyssey` command below handles those calls with
#     Walker, swaync, wpctl and hyprshot, and hands everything to the real Odyssey
#     once ~/.local/bin/odyssey exists.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, lib, ... }:
    let
      withoutOdyssey = {
        Unit.ConditionPathExists = "!%h/.config/hypr/odyssey.lua";
      };

      graphicalService = description: exec: {
        Unit = {
          Description = description;
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = exec;
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      odysseyStandIn = pkgs.writeShellApplication {
        name = "odyssey";
        runtimeInputs = with pkgs; [
          walker
          swaynotificationcenter
          hyprlock
          wireplumber
          hyprshot
          satty
          libnotify
          power-profiles-daemon
          nwg-look
        ];
        text = ''
          real="$HOME/.local/bin/odyssey"
          if [ -x "$real" ]; then
            exec "$real" "$@"
          fi

          if [ "''${1:-}" != ipc ]; then
            notify-send "odyssey" "Odyssey isn't installed; '$*' has no stand-in."
            exit 1
          fi
          shift

          case "$*" in
            "launcher toggle") walker ;;
            "clipboard toggle") walker -m clipboard ;;
            "insights wallpaper") walker -m menus:wallpapers ;;
            "notifications toggle" | "control-center toggle") swaync-client -t -sw ;;
            "settings open") nwg-look ;;
            "session lock") hyprlock ;;
            "audio increment "*) wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "$3%+" ;;
            "audio decrement "*) wpctl set-volume @DEFAULT_AUDIO_SINK@ "$3%-" ;;
            "audio mute") wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
            "audio micmute") wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
            "capture screenshot region both") hyprshot -m region --raw | satty --filename - ;;
            "capture screenshot full copy") hyprshot -m output --clipboard-only ;;
            "capture screenshot active copy") hyprshot -m window -m active --clipboard-only ;;
            "power cycle")
              case "$(powerprofilesctl get)" in
                power-saver) next=balanced ;;
                balanced) next=performance ;;
                *) next=power-saver ;;
              esac
              powerprofilesctl set "$next"
              notify-send "Power profile" "$next"
              ;;
            *) notify-send "odyssey" "No stand-in for '$*' until Odyssey is installed." ;;
          esac
        '';
      };
    in
    {
      home.packages = [
        odysseyStandIn
        pkgs.waybar
        pkgs.swaynotificationcenter
        pkgs.nwg-look
        pkgs.libnotify
        pkgs.pulseaudio # pactl, used by ~/.local/bin/mic-status in the bar
      ];

      # Whole directories, because style.css files @import their themes by relative path.
      xdg.configFile = {
        "waybar".source = ./desktop-shell/waybar;
        "swaync".source = ./desktop-shell/swaync;
        "walker".source = ./desktop-shell/walker;
        "elephant".source = ./desktop-shell/elephant;
      };

      services.elephant.enable = true;
      services.walker = {
        enable = true;
        systemd.enable = true; # `--gapplication-service`, so Walker opens instantly
      };

      systemd.user.services = {
        elephant = withoutOdyssey;
        walker = withoutOdyssey;
        waybar = lib.recursiveUpdate (graphicalService "Waybar" (lib.getExe pkgs.waybar)) withoutOdyssey;
        swaync = lib.recursiveUpdate (graphicalService "Sway Notification Center" (
          lib.getExe' pkgs.swaynotificationcenter "swaync"
        )) withoutOdyssey;
      };
    };
}
