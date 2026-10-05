{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.mpv ];
    };
}
