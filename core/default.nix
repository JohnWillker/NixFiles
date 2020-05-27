# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
# Check for options https://nixos.org/nixos/options.html#

{ config, pkgs, ... }:

# https://github.com/tesq0/nix-config/blob/a11c7a0c7f85694a71d862e8279956bd14c913d8/nixos/xboxdrv.nix
with (import (builtins.fetchGit {
  name = "ghcide-for-nix";
  url = https://github.com/magthe/ghcide-for-nix;
  rev = "927a8caa62cece60d9d66dbdfc62b7738d61d75f";
}) );
let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  homedir = builtins.getEnv "HOME";
  # dftech-tools = pkgs.callPackage ../pkgs/dftech-tools {};
  # obs-v4l2sink = pkgs.callPackage ../pkgs/obs-v4l2sink {};
  krew = pkgs.callPackage ../pkgs/krew {};
  xst = pkgs.callPackage ../pkgs/xst {};
  kind = pkgs.callPackage ../pkgs/kind {};
  kustomize = pkgs.callPackage ../pkgs/kustomize {};
  kubebuilder = pkgs.callPackage ../pkgs/kubebuilder {};
in {
  imports = [
    ./home
    ./secrets
    ./modules
  ];

  nix = {
    trustedUsers = [ "root" "yuri" "yuri.lima"];
    envVars = {
      NIX_GITHUB_PRIVATE_USERNAME = "";
      NIX_GITHUB_PRIVATE_PASSWORD = "";
    };
  };

  environment = {
    variables = {
      EDITOR = "/home/yuri/.nix-profile/bin/vim";
      TERMINAL = "xst";
      SHELL = "fish";
    };

    # For batery
    pathsToLink = [ "/libexec" ];

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      # dftech-tools
      # kubernetes-helm
      # nixos.android-studio-stable
      # obs-v4l2sink
      # unstable.android-studio
      # siege
      # cargo
      # gnumake42
      ag
      appimage-run
      arandr
      argocd
      awscli
      bind
      charles4
      containerd
      deepin.deepin-screenshot
      discord
      docker
      docker-compose
      eksctl
      emacs
      ffmpeg
      firefox
      ghcide
      git
      gitAndTools.diff-so-fancy
      gnumake
      google-chrome-beta
      unstable.gradle
      htop
      jq
      k3s
      k9s
      kbfs
      keybase-go
      killall
      kind
      krew
      kubebuilder
      kubectl
      kustomize
      lazygit
      meld
      minikube
      networkmanager-openconnect
      networkmanager-openvpn
      networkmanagerapplet
      nix-prefetch
      nix-prefetch-git
      obs-studio
      openconnect
      openssl
      parcellite # Manages clipboard sync
      pavucontrol
      pulsemixer
      ranger
      sbt
      sdl-jstest
      smbclient
      stack
      steam
      steam-run
      tilt
      unity3d
      unstable.adoptopenjdk-jre-openj9-bin-11
      unstable.fish
      unstable.go
      unstable.gotools
      unstable.kubernetes-helm
      unstable.metals
      unstable.pbis-open
      unstable.tmux
      unstable.vscode
      unzip
      vgo2nix
      vim
      vlc
      wget
      brightnessctl
      xorg.xhost
      xorg.xprop
      xorg.xwininfo
      xorg.xev
      xst
      zoom-us
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    # This is for openconnect
    permittedInsecurePackages = [
      "openssl-1.0.2u"
    ];
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  # Network
  networking.networkmanager.enable = true;

  # Sound and Bluetooth
  hardware = {
    pulseaudio = {
      enable = true;
      # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
      # Only the full build has Bluetooth support, so it must be selected here.
      package = pkgs.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      extraConfig = ''
        load-module module-bluetooth-policy auto_switch=2
      '';
    };
    bluetooth = {
      enable = true;
      # extraConfig = "
      #   [General]
      #   Enable=Source,Sink,Media,Socket
      # ";
      package = pkgs.bluezFull;
      config = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
  };

  # Enable sound.
  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  # Enable Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  # location
  location = {
    latitude = -23.502428;
    longitude = -46.626527;
  };

  # List services that you want to enable:
  services = {
    redshift = {
      enable = true;
      brightness = {
        day = "1";
        night = "1";
      };
      temperature = {
        # temperature.day = 6500;
        # temperature.night = 2700;
      };
    };

    # It's for auto detecting external monitor and scripts for that
    # It seams that a hard restart fixes it https://forum.manjaro.org/t/hdmi-shows-disconnected-in-xrandr/113606/3
    autorandr.enable = true;

    # It's for battery i suppose
    acpid.enable = true;

    #
    blueman.enable = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    keybase = {
      enable = true;
    };

    kbfs = {
      enable = true;
      mountPoint = "%h/Keybase";
    };

    xserver = {
      # Keyboard config
      layout = "us,br";
      # https://askubuntu.com/questions/445099/whats-the-opposite-of-setxkbmap-option-ctrlnocaps
      xkbOptions = "ctrl:nocaps, seurosign:e, compose:menu, grp:alt_space_toggle";

      displayManager.defaultSession = "none+i3";
      enable = true;
      autorun = true;
      exportConfiguration = true;
      libinput = {
        enable = true;
        naturalScrolling = true;
        tapping =  false;
      };
      config = ''
        Section "InputClass"
          Identifier "mouse accel"
          Driver "libinput"
          MatchIsPointer "on"
          Option "AccelProfile" "flat"
          Option "AccelSpeed" "1.0"
        EndSection
        Section "InputClass"
          Identifier "Mouse Accel MX Ergo Mouse"
          MatchDriver "libinput"
          MatchProduct "MX Ergo Mouse"
          Option "AccelSpeed" "1.0"
        EndSection
      '';

      windowManager = {
        i3 = {
          enable = true;
          extraPackages = with pkgs; [
            dmenu
            i3status
            i3lock
            i3blocks
            acpi
            xclip
            xsel
          ];
          # Keychain
          extraSessionCommands = ''
            eval $(gnome-keyring-daemon --daemonize)
            export SSH_AUTH_SOCK
          '';
        };
      };

      # Install xfce as desktop manager because i3 does not manages windows?
      # https://nixos.wiki/wiki/I3
      desktopManager = {
        xterm.enable = false;
        # Not working
        # wallpaper.mode = "fill";
        xfce = {
          enable = false;
          noDesktop = true;
          enableXfwm = false;
        };
      };
    };

    # Keychain
    gnome3.gnome-keyring.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    groups = {
      "domain users" = {
        members = [ "yuri" "yuri.lima" ];
      };
    };
    users = {
      yuri = {
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" "networkmanager" "audio" ]; # Enable ‘sudo’ for the user.
        initialHashedPassword = "change";
      };
      "yuri.lima" = {
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" "networkmanager" "audio" ]; # Enable ‘sudo’ for the user.
        initialHashedPassword = "change";
      };
    };
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Fonts
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      noto-fonts-emoji
      symbola
      powerline-fonts
      source-code-pro
      fira-code
      fira-mono
      fira-code-symbols
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    # Keychain
    seahorse.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableBrowserSocket = true;
      enableExtraSocket = true;
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8888 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  # /etc/hosts
  # networking.extraHosts = ''
  # '';
}
