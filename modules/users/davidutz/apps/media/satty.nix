# Satty, the screenshot annotator. Mochi's capture preview opens it from its Edit button.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.satty ];

      wayland.windowManager.hyprland.extraConfig = ''
        hl.window_rule({ name = "satty", match = { class = "com.gabm.satty" }, float = true })
      '';
    };
}
