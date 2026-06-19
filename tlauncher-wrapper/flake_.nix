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

  jdk21 = stpkgs.openjdk21;

  jdkWithJFX =
    if jdk21.pname == "openjdk" then
      jdk21.override {
        enableJavaFX = true;
        openjfx21 = stpkgs.openjfx21.override { withWebKit = true; };
      }
    else
      throw "bad jdk variant";

  tlauncherZip = pkgs.fetchzip {
    url = "https://dl1.tlauncher.org/f.php?f=files%2FTLauncher.v17.zip";
    sha256 = "sha256-v/Zv77+fxKoqQB+bXCMlTnoxLZdHr2OZdszllvlhrM0="; # fill in
    stripRoot = false;
  };

  tlauncherWrapper = pkgs.writeShellApplication {
    name = "tlauncher";
    runtimeInputs = [ jdkWithJFX ];
    # pkgs.gtk3 pkgs.glib pkgs.glfw pkgs.mesa pkgs.libGL
    
    # export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
    #   pkgs.gtk3 pkgs.glib pkgs.mesa pkgs.libGL pkgs.glfw
    # ]}:$LD_LIBRARY_PATH
    text = ''
      #!/usr/bin/env bash

      set -euo pipefail
      set -x

      export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ stpkgs.gtk3 stpkgs.glib stpkgs.mesa stpkgs.libGL stpkgs.glfw stpkgs.openal ]}

      export ALSOFT_LOGLEVEL=3
      export ALSOFT_LOGFILE=/tmp/alsoft.log

      export _JAVA_AWT_WM_NONREPARENTING=1
      export AWT_TOOLKIT=MToolKit
      export WM_NAME=LG3D

      ZIP=${tlauncherZip}

      JAR_PATH="TLauncher.jar"

      mkdir -p "$HOME/.tlauncher/"

      TLAUNCHER_DIR="$HOME/.tlauncher"

      if [ ! -e "$TLAUNCHER_DIR/$JAR_PATH" ] || ! cmp -s "$ZIP/$JAR_PATH" "$TLAUNCHER_DIR/$JAR_PATH"; then
        cp "$ZIP/$JAR_PATH" "$TLAUNCHER_DIR/$JAR_PATH"
      fi

      LOCAL_JAR="$TLAUNCHER_DIR/$JAR_PATH"
      
      chmod +w "$LOCAL_JAR"

      TL_JAVA_PATH="$HOME/.tlauncher/starter/jre_default/"

      update_dir() {
      for dir in "$TL_JAVA_PATH"/*/; do
        [ -d "$dir" ] || continue
        pushd "$dir" >/dev/null

        expected_sha=$(shasum -a 1 ${jdkWithJFX}/bin/java | awk '{print $1}')

        CONF_JSON_PATH=jreConfig.json

        actual_sha=$(jq -r '(.resources[] | select(.path | test("jre_default/.+/bin/java"))).sha1 // empty' "$CONF_JSON_PATH")

        # If already correct, skip replacement + JSON update
        if [ -n "$actual_sha" ] && [ "$actual_sha" = "$expected_sha" ]; then
          popd >/dev/null
          continue
        fi

        mv bin/java bin/java.bak
        ln -s ${jdkWithJFX}/bin/java bin/java
        
        SHA=$(shasum -a 1 bin/java | awk '{print $1}')
        SIZE=$(wc -c < bin/java)
        echo new sha1 sum "$SHA" for "$dir"
        
        jq --arg newsha "$SHA" --arg newsize "$SIZE" '(.resources[] | select(.path | test("jre_default/.+/bin/java"))) |= (.sha1 = $newsha | .size = $newsize)' $CONF_JSON_PATH > $CONF_JSON_PATH.tmp && mv $CONF_JSON_PATH.tmp $CONF_JSON_PATH
        
        popd >/dev/null
      done
      }
      
      update_dir

      newEntry='{
        "id": 99,
        "name": "java-nixos",
        "path": "${jdkWithJFX}",
        "args": [
          "-XX:+UnlockExperimentalVMOptions",
          "-XX:+UseG1GC",
          "-XX:G1NewSizePercent\u003d20",
          "-XX:G1ReservePercent\u003d20",
          "-XX:MaxGCPauseMillis\u003d50",
          "-XX:G1HeapRegionSize\u003d32M",
          "-Dfml.ignoreInvalidMinecraftCertificates\u003dtrue",
          "-Dfml.ignorePatchDiscrepancies\u003dtrue",
          "-Djava.net.preferIPv4Stack\u003dtrue"
        ]
      }'

      JAVA_CONFIG_JS="$TLAUNCHER_DIR"/minecraft_tlauncher_java_config.json

      if [ ! -e "$JAVA_CONFIG_JS" ]; then
        echo '{}' > "$JAVA_CONFIG_JS"
      fi

      jq --argjson newEntry "$newEntry" '
        .jvm["99"] = $newEntry
      ' "$JAVA_CONFIG_JS" > "$JAVA_CONFIG_JS".tmp && mv "$JAVA_CONFIG_JS".tmp "$JAVA_CONFIG_JS"

      TLAUNCHER_PROPS="$TLAUNCHER_DIR"/tlauncher-2.0.properties
      if [ ! -e "$TLAUNCHER_PROPS" ]; then
        echo ' ' > "$TLAUNCHER_PROPS"
      fi
      sed -i 's/^minecraft\.java\.selected=.*/minecraft.java.selected=99/' "$TLAUNCHER_PROPS"

      file_path=$(find "$TLAUNCHER_DIR"/starter/cache/https_repo.tlauncher.org/update/lch -maxdepth 1 -type f -name "starter-core-*.jar" -print -quit)
      [ -n "$file_path" ] && echo "Found already existent tlauncher client $file_path. will use it" && LOCAL_JAR="$file_path"

      if command -v nvidia-offload >/dev/null 2>&1; then
        exec nvidia-offload -- ${jdkWithJFX}/bin/java -jar "$LOCAL_JAR"
      fi
      exec ${jdkWithJFX}/bin/java -jar "$LOCAL_JAR"
    '';
  };
in
{
  environment.systemPackages = [ 
    tlauncherWrapper
    jdkWithJFX
    stpkgs.lshw
    stpkgs.gtk3
    stpkgs.glib
    stpkgs.mesa
    stpkgs.libGL
    stpkgs.glfw
    stpkgs.openal
  ];
}
