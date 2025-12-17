{ config, pkgs, ... }:

{
  # TODO please change the username & home directory to your own
  home.username = "sen";
  home.homeDirectory = "/home/sen";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  # xresources.properties = {
  #   "Xft.dpi" = 96;
  # };

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "kitty";
      startup = [
        # Launch Firefox on start
        {command = "firefox";}
        {command = "waybar";}
        {command = "kitty zellij";}
      ];
      defaultWorkspace = "workspace number 1";
    };
    extraConfig = ''
      set $mod Mod4

      input "type:keyboard" {
        xkb_layout us,ru
        xkb_options ctrl:nocaps,grp:win_space_toggle
      }

      input "type:touchpad" {
        natural_scroll enabled
	tap enabled
	accel_profile adaptive
	drag_lock enabled
      }

      # Bind Alt+Tab to switch to next workspace on current output
      bindsym Alt+Tab workspace next_on_output
      # Bind Alt+Shift+Tab to switch to previous workspace on current output
      bindsym Alt+Shift+Tab workspace prev_on_output

      bindsym $mod+Ctrl+l exec swaylock -f --color 051c38
    '';
    systemd.enable = true;
  };
  services.swayidle = {
    enable = true;
    systemdTarget = "sway-session.target"; # or your session target
    timeouts = [
      {
        timeout = 30; # lock screen after 30 seconds idle
        command = "${pkgs.swaylock}/bin/swaylock -f --color 051c38";
      }
      {
        timeout = 60; # 30 seconds after locking, turn off screen
        command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
      }
    ];
  };
  programs.waybar = {
    enable = true;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

    neofetch
    nnn # terminal file manager

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    steam
    telegram-desktop
    sct

    font-awesome
    jetbrains-mono

    gnumake
    glibc
    gcc_multi
    python3
  ];
  
  fonts.fontconfig.enable = true;
  
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      llvm-vs-code-extensions.vscode-clangd
    ];
  };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Arseny Staroverov";
    userEmail = "arsen2001god@bk.ru";
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
      git_branch.disabled = true;
      git_status.disabled = true;
      git_state.disabled = true;
    };
  };

  programs.kitty = {
    enable = true;
    extraConfig = ''
      map ctrl+[ send_text all \x1b
    '';
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      export EDITOR=nvim
      export VISUAL=nvim
      sct 2500
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
      j = "just";
      y = "yazi";
      laz = "lazygit";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
