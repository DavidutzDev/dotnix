# Wayland clipboard tools.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.wl-clipboard ];

      # Keeps the clipboard alive after the app that copied closes.
      services.wl-clip-persist.enable = true;

      # Start every session with an empty clipboard.
      wayland.windowManager.hyprland.extraConfig = ''
        hl.on("hyprland.start", function()
          hl.exec_cmd("sh -c 'wl-copy --clear; wl-copy --primary --clear'")
        end)
      '';
    };
}
