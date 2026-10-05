# `/` is empty after every boot. Requirements on the host's disk layout:
#   - `/` is a btrfs subvolume (fileSystems."/" has a subvol= option)
#   - /persist is a separate filesystem or subvolume
# The initrd moves the old root subvolume to old_roots/ and creates an empty one.
# This module also lists the system state that survives, stored under /persist and
# bind-mounted back. /home and /nix should be their own subvolumes, so nothing
# inside them needs listing here.
#
# Something lost its settings after a reboot? Find where it writes
# (`sudo find / -xdev -newer /etc/os-release -not -path '/proc/*'`) and add the path.
# https://nix-community.github.io/preservation/
{ inputs, ... }: {
  flake.nixosModules.impermanence =
    {
      config,
      lib,
      pkgs,
      utils,
      ...
    }:
    let
      # Only keep a service's state on hosts that run the service.
      whenEnabled = cond: dirs: lib.optionals cond dirs;

      root = config.fileSystems."/";
      rootDeviceUnit = "${utils.escapeSystemdPath root.device}.device";
      subvolOption = lib.findFirst (lib.hasPrefix "subvol=") null root.options;
      rootSubvol = lib.removePrefix "/" (lib.removePrefix "subvol=" subvolOption);
    in
    {
      imports = [ inputs.preservation.nixosModules.preservation ];

      assertions = [
        {
          assertion = root.fsType == "btrfs" && subvolOption != null;
          message = "impermanence: `/` must be a btrfs subvolume (subvol= in its mount options).";
        }
      ];

      # Preservation bind-mounts from /persist while still in the initrd.
      fileSystems."/persist".neededForBoot = true;

      # Before the initrd mounts `/`, move the old root subvolume to old_roots/ and
      # create an empty one. Old roots are kept 14 days, so a file you forgot to
      # preserve can still be recovered:
      #   sudo mount -o subvol=/ <root device> /mnt && ls /mnt/old_roots
      boot.initrd.systemd.initrdBin = [
        pkgs.btrfs-progs
        pkgs.findutils
      ];
      boot.initrd.systemd.services.rollback-root = {
        description = "Replace the root subvolume with an empty one";
        wantedBy = [ "initrd.target" ];
        requires = [ rootDeviceUnit ];
        after = [ rootDeviceUnit ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir -p /btrfs
          mount -t btrfs -o subvol=/ ${root.device} /btrfs
          mkdir -p /btrfs/old_roots

          if [ -e "/btrfs/${rootSubvol}" ]; then
            stamp=$(date -u -d "@$(stat -c %Y "/btrfs/${rootSubvol}")" +%Y-%m-%dT%H%M%S)
            mv "/btrfs/${rootSubvol}" "/btrfs/old_roots/$stamp"
          fi

          # systemd creates nested subvolumes (/var/lib/machines, /var/lib/portables),
          # which have to be deleted before their parent.
          delete_subvolume() {
            btrfs subvolume list -o "$1" | cut -d ' ' -f 9- | while read -r sub; do
              delete_subvolume "/btrfs/$sub"
            done
            btrfs subvolume delete "$1"
          }
          find /btrfs/old_roots -mindepth 1 -maxdepth 1 -mtime +14 | while read -r old; do
            delete_subvolume "$old"
          done

          btrfs subvolume create "/btrfs/${rootSubvol}"
          umount /btrfs
        '';
      };

      preservation.enable = true;
      preservation.preserveAt."/persist" = {
        files = [
          # Symlink so systemd-machine-id-commit can write through it (see below).
          # The target must exist: for an empty file systemd generates an id and
          # mounts it on top; for a dangling symlink it gives up and dbus fails.
          {
            file = "/etc/machine-id";
            inInitrd = true;
            how = "symlink";
            configureParent = true;
            createLinkTarget = true;
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key";
            how = "symlink";
            configureParent = true;
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key.pub";
            how = "symlink";
            configureParent = true;
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key";
            how = "symlink";
            configureParent = true;
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key.pub";
            how = "symlink";
            configureParent = true;
          }
          {
            file = "/var/lib/systemd/random-seed";
            how = "symlink";
            inInitrd = true;
            configureParent = true;
          }
          # Host key for systemd-creds (LoadCredentialEncrypted=). Without it, credentials
          # encrypted before a reboot can't be read, e.g. libvirt's secrets-encryption-key.
          # Bind-mounted (systemd won't follow a symlink here), and only once the file
          # exists under /persist: `sudo systemd-creds setup` and copy it there.
          # Preservation re-applies the mode on every boot, and systemd refuses the key
          # ("Failed to determine local credential key") unless it is 0400.
          {
            file = "/var/lib/systemd/credential.secret";
            mode = "0400";
            inInitrd = true;
            configureParent = true;
          }
        ];

        directories = [
          # uid/gid assignments; without it, users could get new ids on each boot
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
          "/var/log"
          "/var/lib/systemd/timers"
          "/var/lib/systemd/coredump"
          "/var/lib/systemd/rfkill"
          "/var/lib/systemd/backlight"
          "/var/lib/AccountsService"
        ]
        ++ whenEnabled config.networking.networkmanager.enable [
          "/etc/NetworkManager/system-connections"
          "/var/lib/NetworkManager"
        ]
        ++ whenEnabled config.hardware.bluetooth.enable [ "/var/lib/bluetooth" ]
        ++ whenEnabled config.services.tailscale.enable [ "/var/lib/tailscale" ]
        ++ whenEnabled config.virtualisation.docker.enable [
          "/var/lib/docker" # volumes and container metadata
          "/var/lib/containerd" # images and layers (Docker's containerd image store)
        ]
        ++ whenEnabled config.virtualisation.libvirtd.enable [ "/var/lib/libvirt" ]
        ++ whenEnabled config.services.flatpak.enable [ "/var/lib/flatpak" ]
        ++ whenEnabled config.services.power-profiles-daemon.enable [ "/var/lib/power-profiles-daemon" ]
        ++ whenEnabled config.services.upower.enable [ "/var/lib/upower" ];
      };

      # machine-id: let systemd commit the generated id to /persist on first boot.
      # From preservation's own TODO for current systemd.
      systemd.services.systemd-machine-id-commit = {
        unitConfig.ConditionPathIsMountPoint = [
          ""
          "/persist/etc/machine-id"
        ];
        serviceConfig.ExecStart = [
          ""
          "systemd-machine-id-setup --commit --root /persist"
        ];
      };

      # /etc/shadow is recreated every boot, so a password set with `passwd` would
      # be lost. Passwords come from the config instead (hashedPasswordFile).
      users.mutableUsers = false;

      # sudo's "lecture" marker lives in /var/db and would show on every boot.
      security.sudo.extraConfig = "Defaults lecture = never";
    };
}
