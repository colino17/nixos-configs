{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neofetch
    cmatrix
    appimage-run
    pciutils
    geekbench
    e2fsprogs
    iperf
  ];
}
