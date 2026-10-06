# Steam and the parts of cachyos-gaming-meta that need system support.
# Launchers without system needs (Lutris, Heroic, Prism) are in users/davidutz/apps/games/.
{
  flake.nixosModules.gaming = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ]; # replaces protonup-qt
    };
    programs.gamemode.enable = true;
    programs.gamescope.enable = true;
  };
}
