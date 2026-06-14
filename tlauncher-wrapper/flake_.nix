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


{ pkgs, lib, stable-nixpkgs, ... }:  # Receive stable pkgs as argument
let
  # stpkgs = stable-nixpkgs.legacyPackages.${pkgs.system};
  stpkgs = pkgs;
  # Java21 from stable input (cached!)
  java21 = stpkgs.openjdk21.override {
    enableJavaFX = true;
    openjfx_jdk = stpkgs.openjfx.override {
      withWebKit = true;
    };
  };

  tlauncherZip = pkgs.fetchzip {
    url = "https://dl1.tlauncher.org/f.php?f=files%2FTLauncher.v17.zip";
    sha256 = "sha256-v/Zv77+fxKoqQB+bXCMlTnoxLZdHr2OZdszllvlhrM0="; # fill in
    stripRoot = false;
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

      set -euo pipefail
      set -x

      export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ stpkgs.gtk3 stpkgs.glib stpkgs.mesa stpkgs.libGL stpkgs.glfw ]}

      ZIP=${tlauncherZip}

      JAR_PATH="TLauncher.jar"

      mkdir -p "$HOME/.tlauncher/"

      TLAUNCHER_DIR="$HOME/.tlauncher"

      cp "$ZIP/$JAR_PATH" "$TLAUNCHER_DIR/$JAR_PATH"

      LOCAL_JAR="$TLAUNCHER_DIR/$JAR_PATH"
      
      chmod +w "$LOCAL_JAR"

      TL_JAVA_PATH="$HOME/.tlauncher/starter/jre_default/"

      update_dir() {
      for dir in "$TL_JAVA_PATH"/*/; do
        [ -d "$dir" ] || continue
        pushd "$dir" >/dev/null
        mv bin/java bin/java.bak
        ln -s ${java21}/bin/java bin/java
        
        SHA=$(shasum -a 1 bin/java | awk '{print $1}')
        SIZE=$(wc -c < bin/java)
        echo new sha1 sum "$SHA" for "$dir"

        CONF_JSON_PATH=jreConfig.json
        
        jq --arg newsha "$SHA" --arg newsize "$SIZE" '(.resources[] | select(.path | test("jre_default/.+/bin/java"))) |= (.sha1 = $newsha | .size = $newsize)' $CONF_JSON_PATH > $CONF_JSON_PATH.tmp && mv $CONF_JSON_PATH.tmp $CONF_JSON_PATH
        
        popd >/dev/null
      done
      }
      
      update_dir

      exec ${java21}/bin/java -jar "$LOCAL_JAR"
    '';
  };
in
{
  environment.systemPackages = [ 
    tlauncherWrapper
    java21
    stpkgs.gtk3
    stpkgs.glib
    stpkgs.mesa
    stpkgs.libGL
    stpkgs.glfw
  ];
}
