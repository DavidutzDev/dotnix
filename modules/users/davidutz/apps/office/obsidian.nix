# Not programs.obsidian: it manages vault settings, which live in the vaults for now.
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.obsidian ];
    };
}
