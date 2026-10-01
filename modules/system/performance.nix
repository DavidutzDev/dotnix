# The tuning CachyOS ships (cachyos-settings, ananicy-cpp, zram-generator).
{
  flake.nixosModules.performance = { pkgs, ... }: {
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    # CachyOS: zram-size = ram, zstd, priority 100, no disk swap.
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 100;
      priority = 100;
    };

    # /usr/lib/sysctl.d/70-cachyos-settings.conf, 50-pid-max.conf, 99-splitlock.conf
    boot.kernel.sysctl = {
      "vm.swappiness" = 100;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_bytes" = 268435456;
      "vm.dirty_background_bytes" = 67108864;
      "vm.dirty_writeback_centisecs" = 1500;
      "vm.page-cluster" = 0;
      "kernel.nmi_watchdog" = 0;
      "kernel.printk" = "3 3 3 3";
      "kernel.kptr_restrict" = 2;
      "kernel.pid_max" = 4194304;
      "kernel.split_lock_mitigate" = 0;
      "net.core.netdev_max_backlog" = 4096;
      "fs.file-max" = 2097152;
      "fs.inotify.max_user_watches" = 524288;
    };
    boot.kernelParams = [ "nowatchdog" ];

    services.fstrim.enable = true;
    services.power-profiles-daemon.enable = true;
  };
}
