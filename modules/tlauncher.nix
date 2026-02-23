{ pkgs, lib, stable, ... }:  # Receive stable pkgs as argument let
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
