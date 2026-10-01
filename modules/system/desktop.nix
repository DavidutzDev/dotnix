# Desktop services that aren't tied to the compositor: file manager backends,
# Flatpak (Sober, Bottles, SysDVR), Sunshine streaming, and running prebuilt binaries.
{
  flake.nixosModules.desktop = {
    services.gvfs.enable = true; # MTP, trash, network shares in Nautilus/Thunar
    services.tumbler.enable = true; # thumbnails
    services.udisks2.enable = true;

    services.flatpak.enable = true;

    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true; # KMS capture
      openFirewall = true;
    };

    # Prebuilt binaries (npm/bun native modules, Unreal Engine, downloaded CLIs)
    # expect /lib64/ld-linux-x86-64.so.2; nix-ld provides it.
    programs.nix-ld.enable = true;
  };
}
