# Docker, libvirt/QEMU and quickemu (home-sweet-home: system/docker, apps/virt/quickemu).
# The single-GPU passthrough kernel settings are host-specific and live in the host.
{
  flake.nixosModules.virtualisation = { pkgs, ... }: {
    virtualisation.docker.enable = true;

    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      quickemu
      docker-compose
    ];
  };
}
