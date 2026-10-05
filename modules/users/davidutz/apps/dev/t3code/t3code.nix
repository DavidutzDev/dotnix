# Control surface for coding agents, local or on another machine. Machines that run
# the agents themselves also get the agents profile (agents/).
#
# 0.0.44, from nixpkgs master (_package/), built against our pinned nixpkgs. Why:
# the T3 state restored from CachyOS was written by a nightly with database
# migrations up to 53, and older releases don't know them.
#
# One change to the copied package: a postFixup in unwrapped.nix ("Added for
# dotnix") so node-pty's prebuilt binary finds libstdc++. Delete _package/ and go
# back to pkgs.t3code once the pinned nixpkgs has 0.0.44 or newer, after checking
# that the terminal works there.
{
  flake.homeModules.davidutzDesktop =
    { lib, pkgs, ... }:
    let
      t3code = pkgs.callPackage ./_package/package.nix { };
    in
    {
      warnings = lib.optional (lib.versionAtLeast pkgs.t3code.version t3code.version) ''
        nixpkgs now has t3code ${pkgs.t3code.version}: delete
        modules/users/davidutz/apps/dev/t3code/_package and use pkgs.t3code.
      '';

      home.packages = [ t3code ];
    };
}
