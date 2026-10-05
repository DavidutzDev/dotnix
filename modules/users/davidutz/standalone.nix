# Home-manager without NixOS: the entry point on every machine that isn't a NixOS host
# here (the pi, another distro with Nix installed). NixOS hosts get the same modules
# through nixosModules.davidutz instead.
#
#   home-manager switch --flake ~/personal/dotnix   # first run: nix run home-manager -- switch --flake ...
#   update / rebuild / cleanup                        # zsh aliases afterwards, through nh
#
# home-manager picks `davidutz@<hostname>` and falls back to `davidutz` (terminal setup,
# x86_64-linux). A new machine that needs more than that gets an entry in `machines`.
{
  self,
  inputs,
  lib,
  ...
}:
let
  machines = {
    pi = {
      system = "aarch64-linux";
      profiles = [ ];
    };
  };

  standalone = {
    # Not NixOS: lets home-manager set XDG_DATA_DIRS, the nix profile and the like.
    targets.genericLinux.enable = true;

    # On NixOS, nh comes from system/nix.nix.
    programs.nh = {
      enable = true;
      flake = "/home/davidutz/personal/dotnix";
    };
    programs.zsh.shellAliases = {
      update = "nh home switch --update";
      rebuild = "nh home switch";
      cleanup = "nh clean user --keep 5";
    };
  };

  mkHome =
    { system, profiles }:
    inputs.home-manager.lib.homeManagerConfiguration {
      # Own import instead of withSystem's pkgs: the desktop and agents profiles need
      # allowUnfree, which NixOS hosts set in system/nix.nix.
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      modules = [
        self.homeModules.davidutz
        standalone
      ]
      ++ profiles;
    };
in
{
  flake.homeConfigurations = {
    davidutz = mkHome {
      system = "x86_64-linux";
      profiles = [ ];
    };
  }
  // lib.mapAttrs' (host: machine: lib.nameValuePair "davidutz@${host}" (mkHome machine)) machines;
}
