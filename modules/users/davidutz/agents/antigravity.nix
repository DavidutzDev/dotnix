# Antigravity's CLI, `agy`.
{
  flake.homeModules.davidutzAgents =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.antigravity-cli ];
    };
}
