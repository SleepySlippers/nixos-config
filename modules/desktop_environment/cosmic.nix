# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.desktopManager.cosmic.xwayland.enable = true;

  # environment.systemPackages = [
  #   (pkgs.cosmic-greeter.overrideAttrs (oldAttrs: {
  #     src = pkgs.fetchFromGitHub {
  #       owner  = "SleepySlippers";                    # Your GitHub username
  #       repo   = "cosmic-greeter";         # Your repo name
  #       rev    = "master";                   # branch/tag/commit
  #       hash   = "sha256-crtMMNhE9VqygUkdYqimjedd79la7GY9vAqTT0fzjOA=";  # Empty first
  #     };
  #      # Fix the null VERGEN_GIT_SHA
  #     env.VERGEN_GIT_SHA = "custom-fork";
  #     # ADD THIS - critical for Cargo.lock changes
  #     cargoSha256 = "";  # Empty first
  #   }))
  # ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
