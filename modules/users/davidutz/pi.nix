{ inputs, withSystem, config, ... }:
{
  flake.homeConfigurations."davidutz@pi" = withSystem "aarch64-linux" ({ pkgs, ... }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ config.flake.homeModules.davidutz ];
    }
  );
}