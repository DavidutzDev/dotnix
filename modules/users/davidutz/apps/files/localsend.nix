# Needs its port open on the host to receive (TODO.md, section 6).
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.localsend ];
    };
}
