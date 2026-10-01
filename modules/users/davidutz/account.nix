# Everything in modules/users/davidutz/ adds to one of these modules:
#   nixosModules.davidutz          the account, plus system bits the user needs (login shell)
#   homeModules.davidutz           terminal setup, used everywhere including the pi
#   homeModules.davidutzDesktop    Hyprland and GUI apps, for machines with a screen
#   homeModules.davidutzAgents     coding agents, for machines that run them
# Each file sets whichever it needs; the module system merges them.
#
# The NixOS account only brings the terminal setup. Each host adds the other profiles:
#   hm.imports = with self.homeModules; [ davidutzDesktop davidutzAgents ];
{ self, inputs, ... }: {
  flake.nixosModules.davidutz = { config, lib, ... }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      # `hm.<option>` in any NixOS module sets home-manager.users.davidutz.<option>.
      (inputs.nixpkgs.lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" "davidutz" ])
    ];

    # Same uid and group as on CachyOS: everything on the bulkfast disk (personal, work,
    # games) is owned by 1000:1000, and stays readable only if these numbers match.
    users.groups.davidutz.gid = 1000;
    users.users.davidutz = {
      isNormalUser = true;
      uid = 1000;
      group = "davidutz";
      description = "David Gheghea";
      # Join a service's group only on hosts that enable the service.
      extraGroups =
        [ "users" "networkmanager" "wheel" "video" "audio" "input" ]
        ++ lib.optional config.virtualisation.docker.enable "docker"
        ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd"
        ++ lib.optional config.programs.gamemode.enable "gamemode"
        ++ lib.optional config.services.seatd.enable "seat";
      # The password is set per host (hashedPasswordFile), see hosts/*/configuration.nix.
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "hm-backup";
    hm.imports = [ self.homeModules.davidutz ];
  };

  flake.homeModules.davidutz = {
    home.username = "davidutz";
    home.homeDirectory = "/home/davidutz";
    home.stateVersion = "26.05";

    programs.home-manager.enable = true;
  };

  flake.homeModules.davidutzDesktop.imports = [ self.homeModules.davidutz ];
}
