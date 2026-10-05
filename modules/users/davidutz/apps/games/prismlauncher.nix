# Minecraft launcher.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.prismlauncher ];
    };
}
