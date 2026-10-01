{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";

    # Declarative disk layout: partitions, filesystems, btrfs subvolumes.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Keeps chosen state across the root wipe on every boot.
    preservation.url = "github:nix-community/preservation";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Plain files (Hyprland Lua, tmux, ghostty) shared with the CachyOS install.
    # Run `nix flake update dotfiles` after pushing changes there.
    dotfiles = {
      url = "github:DavidutzDev/dotfiles";
      flake = false;
    };
  };

  outputs = inputs@{
    flake-parts,
    home-manager,
    import-tree,
    nixpkgs,
    ...
  }: flake-parts.lib.mkFlake { inherit inputs; } (import-tree ./modules);
}
