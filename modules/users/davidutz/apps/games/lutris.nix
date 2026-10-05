# Steam itself is a NixOS module (system/gaming.nix).
{
  flake.homeModules.davidutzDesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.lutris ];
    };
}
