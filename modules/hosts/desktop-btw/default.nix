{ self, inputs, ... }: {
  # Named after networking.hostName so `nh os switch` finds it without -H.
  flake.nixosConfigurations.desktop-btw = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.desktop-btwConfiguration
    ];
  };
}
