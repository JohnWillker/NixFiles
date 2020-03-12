# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  homedir = builtins.getEnv "HOME";
  krew = pkgs.callPackage ../pkgs/krew {};
  #dftech-tools = pkgs.callPackage ../pkgs/dftech-tools {};
in {
  imports = [
    ./home
    ./secrets
  ];

  environment = {
    variables = {
      EDITOR = "vim";
      TERMINAL = "xst";
      SHELL = "fish";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "openssl-1.0.2u"
    ];
    packageOverrides = pkgs: {
        unstable = import unstableTarball {
          config = config.nixpkgs.config;
        };
      };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #dftech-tools
    ag
    arandr
    discord
    docker
    docker-compose
    emacs
    git
    gitAndTools.diff-so-fancy
    go
    google-chrome-beta
    kbfs
    keybase-go
    krew
    kubectl
    kubernetes-helm
    meld
    networkmanager-openconnect
    networkmanager-openvpn
    networkmanagerapplet
    openconnect
    pulsemixer
    ranger
    stack
    unstable.fish
    unstable.pbis-open
    unstable.tmux
    unstable.xst
    vim
    vscode
    wget
    xorg.xbacklight
    xorg.xhost
    xst
    zoom-us
  ];

  # Network
  networking.networkmanager.enable = true;

  # Sound and Bluetooth
  hardware = {
    pulseaudio = {
      enable = true;

      # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
      # Only the full build has Bluetooth support, so it must be selected here.
      package = pkgs.pulseaudioFull;
    };
    bluetooth = {
      enable = true;
      extraConfig = "
        [General]
        Enable=Source,Sink,Media,Socket
      ";
    };
  };

  # Enable sound.
  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  #
  virtualisation.docker.enable = true;

  # List services that you want to enable:
  services = {
    # redshift = {
    #   enable = false;
    #   latitude = "-23.502428";
    #   longitude = "-46.626527";
    #   temperature.day = 6500;
    #   temperature.night = 2700;
    # };

    autorandr.enable = true;

    # ???????
    acpid.enable = true;

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
      enable = true;
      autorun = true;
      exportConfiguration = true;
      libinput.enable = true;
      layout = "br";
      windowManager = {
        default = "i3";
        i3 = {
          enable = true;
          extraPackages = with pkgs; [
            dmenu
            i3status
            i3lock
            i3blocks
            acpi
            xclip
          ];
        };
      };

      desktopManager = {
        default = "none";
        xterm.enable = false;
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users = {
      yuri = {
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" "networkmanager" ]; # Enable ‘sudo’ for the user.
        initialHashedPassword = "change";
      };
      # root = {
      #   isNormalUser = true;
      #   extraGroups = [ "wheel" "docker" "networkmanager" ];
      # };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.light.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "br-abnt2";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      # Must have
      powerline-fonts
      source-code-pro
      # hmm
      source-code-pro
      fira-code
      fira-mono
      fira-code-symbols
      freefont_ttf
      # Don`t know
      # anonymousPro
      # corefonts
      # dejavu_fonts
      # noto-fonts
      # freefont_ttf
      # google-fonts
      # inconsolata
      # liberation_ttf
      # terminus_font
      # ttf_bitstream_vera
      # ubuntu_font_family
    ];
  };
}
