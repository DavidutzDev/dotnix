# Steering wheel settings. Needs its udev rules on the host.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.oversteer ];
    };
}
