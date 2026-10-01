# VM test for the root wipe and preservation, using the real disk layout of test-vm
# (shrunk ESP: the test disks are 4 GiB). Runs with `nix flake check` and needs KVM.
#
# It checks that disko's format step is idempotent (disko's own test harness formats
# twice), that `/` is empty after a reboot, and that /persist, /home, the machine-id
# and the SSH host key survive it.
{ self, inputs, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    {
      checks = lib.optionalAttrs (system == "x86_64-linux") {
        impermanence = inputs.disko.lib.testLib.makeDiskoTest {
          inherit pkgs;
          name = "impermanence";
          disko-config = lib.recursiveUpdate self.diskoConfigurations.test-vm {
            disko.devices.disk.system.content.partitions.ESP.size = "512M";
          };
          extraSystemConfig = {
            imports = [ self.nixosModules.impermanence ];
            boot.initrd.systemd.enable = true;
            services.openssh.enable = true; # its host keys are preserved as symlinks
          };
          extraTestScript = ''
            def no_failed_units():
                failed = machine.succeed("systemctl --failed --no-legend --plain").strip()
                assert failed == "", f"failed units:\n{failed}"

            machine.wait_for_unit("multi-user.target")
            machine.wait_for_unit("sshd.service")
            no_failed_units()

            # state written during the first boot
            machine.succeed("test -L /etc/machine-id")
            machine_id = machine.succeed("cat /etc/machine-id").strip()
            host_key = machine.succeed("cat /etc/ssh/ssh_host_ed25519_key.pub").strip()
            machine.succeed("touch /etc/should-vanish /home/should-stay")
            machine.succeed("mkdir -p /var/log/probe && touch /var/log/probe/should-stay")
            machine.succeed("sync")

            machine.shutdown()
            machine.start()
            machine.wait_for_unit("multi-user.target")
            machine.wait_for_unit("sshd.service")
            no_failed_units()

            machine.fail("test -e /etc/should-vanish")
            machine.succeed("test -e /home/should-stay")
            machine.succeed("test -e /var/log/probe/should-stay")
            assert machine.succeed("cat /etc/machine-id").strip() == machine_id, "machine-id changed"
            assert machine.succeed("cat /etc/ssh/ssh_host_ed25519_key.pub").strip() == host_key, "ssh host key changed"

            # the previous root is kept for recovery
            machine.succeed("mkdir -p /top && mount -o subvol=/ $(findmnt -no SOURCE /persist | cut -d[ -f1) /top")
            machine.succeed("test -n \"$(ls /top/old_roots)\"")
          '';
        };
      };
    };
}
