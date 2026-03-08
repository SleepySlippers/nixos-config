# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the XFCE Desktop Environment.
  # services.displayManager.gdm.enable = true;
  # services.xserver.displayManager.defaultSession = "sway";
  # services.xserver.desktopManager.xfce.enable = true;
  
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    displayManager.lightdm.greeters.gtk.enable = true;
    videoDrivers = [ "nvidia" ];
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    layout = "us,ru";
    xkbOptions = "ctrl:nocaps,grp:win_space_toggle";
  };
  services.displayManager.defaultSession = "xfce";

  # security.polkit.enable = true; # for sway
  # programs.sway = {
  #   enable = true;
  #   wrapperFeatures.gtk = true;
  # };
  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       # Use the tuigreet binary from nixpkgs
  #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'sway --unsupported-gpu'";
  #       user = "greeter";  # the user greetd runs as for greeter
  #     };
  #   };
  # };

  # Configure keymap in X11
  # services.xserver.xkb = {
  #   layout = "us,ru";
  #   variant = "";
  #   options = "ctrl:nocaps";
  # };

  # console = { useXkbConfig = true; };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
