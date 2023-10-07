{ config, pkgs, ... }:

{
  imports =
    [
      ../services/base.nix
      ../services/uefi.nix
      ../services/btrfs.nix
      ../users/colin.nix
    ];

##################
### NETWORKING ###
##################
  networking = {
    hostName = "khonsu";
    interfaces.enp1s0 = {
      wakeOnLan.enable = true;
      ipv4.addresses = [ {
        address = "10.17.10.19";
        prefixLength = 24;
      } ];
    };
    defaultGateway = "10.17.10.1";
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];
  };

############
## MOUNTS ##
############
  fileSystems."/" =
    { fsType = "btrfs";
      options = [ "compress=zstd" "subvol=root" ];
    };
    
  fileSystems."/Storage/Configs" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=Configs" ];
    };

  fileSystems."/Storage/Files" =
    { device = "/dev/disk/by-label/storage";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=Files" ];
    };

  fileSystems."/Storage/Media" =
    { device = "/dev/disk/by-label/storage";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=Media" ];
    };

  fileSystems."/Storage/Recordings" =
    { device = "/dev/disk/by-label/recordings";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=Recordings" ];
    };

  fileSystems."/Storage/Snapshots" =
    { device = "/dev/disk/by-label/storage";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=Snapshots" ];
    };

############
## SHARES ##
############
  services.nfs.server = {
    enable = true;
    createMountPoints = true;
    exports = ''
      /Storage *(ro,no_subtree_check,fsid=0)
      /Storage/Configs *(fsid=111,rw,sync,no_subtree_check)
      /Storage/Files *(fsid=222,rw,sync,no_subtree_check)
      /Storage/Media *(fsid=333,rw,sync,no_subtree_check)
      /Storage/Recordings *(fsid=444,rw,sync,no_subtree_check)
      /Storage/Snapshots *(fsid=555,rw,sync,no_subtree_check)
    '';
  };  
  
#############
## BACKUPS ##
#############
  services.btrbk.instances = {
    local = {
      onCalendar = "daily";
      settings = {
        snapshot_dir = "/Storage/Snapshots";
        snapshot_preserve_min = "2d";
        snapshot_create = "always";
        snapshot_preserve = "3d 2w 2m";
        subvolume."/Storage/Files" = { };
        subvolume."/Storage/Media" = { };
      };
    };
    config = {
      onCalendar = "daily";
      settings = {
        snapshot_dir = "/.snapshots";
        snapshot_preserve_min = "2d";
        snapshot_create = "always";
        snapshot_preserve = "3d 2w 2m";
        subvolume."/Storage/Configs" = { };
      };
    };
  };
  
##########################
### VERSION AND REBOOT ###
##########################
  system = {
    stateVersion = "22.11";
    autoUpgrade.allowReboot = true;
  };
  
}
