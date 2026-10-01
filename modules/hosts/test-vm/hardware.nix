# Hardware of desktop-btw (Gigabyte B550M AORUS ELITE, Ryzen 5 5600X, GTX 1060 6GB),
# from the running CachyOS install (lspci -k, lsmod). Disks and filesystems are
# in disko.nix.
{
  flake.nixosModules.desktop-btwHardware = { lib, modulesPath, ... }: {
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    boot.kernelModules = [ "kvm-amd" ];

    # sda and sdb are Windows NTFS disks. The Windows VM uses sda as a raw disk.
    boot.supportedFilesystems = [ "ntfs" ];

    boot.tmp.useTmpfs = true;
    swapDevices = [ ];

    hardware.cpu.amd.updateMicrocode = true;
    hardware.enableRedistributableFirmware = true;
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
