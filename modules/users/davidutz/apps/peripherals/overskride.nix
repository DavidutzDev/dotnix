# Bluetooth manager. Needs hardware.bluetooth on the host.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.overskride ];
    };
}
