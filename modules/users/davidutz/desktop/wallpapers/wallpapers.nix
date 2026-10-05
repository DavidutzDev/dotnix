# Wallpaper daemon (awww) and the wallpapers in ~/Pictures/Wallpapers.
{
  flake.homeModules.davidutzDesktop = {
    services.awww.enable = true;

    # Linked one by one, so wallpapers added by hand stay put.
    home.file."Pictures/Wallpapers" = {
      source = ./images;
      recursive = true;
    };
  };
}
