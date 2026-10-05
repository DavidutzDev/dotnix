# Gaming mouse settings. Needs services.ratbagd on the host.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.piper ];
    };
}
