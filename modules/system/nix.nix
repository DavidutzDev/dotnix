# Nix itself: flakes, store cleanup, and `nh` as the rebuild front end.
{
  flake.nixosModules.nix = {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
    };

    nixpkgs.config.allowUnfree = true;

    # nh replaces nix.gc: `nh clean` keeps the newest generations instead of
    # deleting by age, and `nh os switch` shows a package diff before switching.
    programs.nh = {
      enable = true;
      flake = "/home/davidutz/personal/dotnix";
      clean = {
        enable = true;
        extraArgs = "--keep 5 --keep-since 7d";
      };
    };
  };
}
