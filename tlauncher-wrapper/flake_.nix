# minecraft-flake/flake.nix
# {
#   inputs = {
#     nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
#     tlauncher-archive.url = "https://your-tlauncher-url.com/archive.zip";
#   };
#
#   outputs = { self, nixpkgs-stable, tlauncher-archive, ... }: {
#     # Export as NixOS module
#     nixosModules.minecraft = import ./minecraft.nix self nixpkgs-stable tlauncher-archive;
#
#     # Also export standalone packages
#     packages.x86_64-linux.tlauncher = self.nixosModules.minecraft.packages.tlauncher;
#   };
# }


{ pkgs, lib, stable, ... }:  # Receive stable pkgs as argument
let
  # Java21 from stable input (cached!)
  java21 = stable.legacyPackages.${pkgs.system}.openjdk21.override {
    enableJavaFX = true;
    openjfx_jdk = stable.legacyPackages.${pkgs.system}.openjfx.override {
      withWebKit = true;
    };
  };

  tlauncherWrapper = pkgs.writeShellApplication {
    name = "tlauncher";
    runtimeInputs = [ java21 ];
    # pkgs.gtk3 pkgs.glib pkgs.glfw pkgs.mesa pkgs.libGL
    
    # export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
    #   pkgs.gtk3 pkgs.glib pkgs.mesa pkgs.libGL pkgs.glfw
    # ]}:$LD_LIBRARY_PATH
    text = ''
      #!/usr/bin/env bash

      exec ${java21}/bin/java -jar 
    '';
  };
in
{
  environment.systemPackages = [ tlauncherWrapper ];
}
