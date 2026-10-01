{ inputs, ...}: {
  imports = [
    inputs.home-manager.flakeModules.home-manager
    inputs.flake-parts.flakeModules.modules
    inputs.disko.flakeModules.disko # adds the diskoConfigurations output
  ];
  systems = [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  # `nix fmt` formats every .nix file in the repo.
  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixfmt-tree;
  };
}
