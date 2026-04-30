{ pkgs, ... }:
let
  # Pinned ahead of nixpkgs (which has 4.82.2). Fleet >= 4.84 needs Go 1.26.
  # Drop this override when nixpkgs catches up to >= 4.84.0.
  fleetctl = (pkgs.fleetctl.override {
    buildGoModule = pkgs.buildGo126Module;
  }).overrideAttrs (_: rec {
    version = "4.84.0";
    src = pkgs.fetchFromGitHub {
      owner = "fleetdm";
      repo = "fleet";
      tag = "fleet-v${version}";
      hash = "sha256-jwmb7c55/u3FZ9U5gG6tJUbKv8MWuL6rv5dvqlhqQSM=";
    };
    vendorHash = "sha256-KdKCEqt1FpeHH8SKCHan1KV+adHoBod9YLvEVrId1tw=";
  });

  commonPackages = with pkgs; [
    # General packages for development and system management
    bat
    coreutils
    openssh

    # Font
    nerd-fonts.monaspace

    # Text and terminal utilities
    jq
    tree
    ripgrep
    ghostty-bin

    # devtools
    direnv
    devenv
    fleetctl

    # Nix
    nil
    nixd
    nix-tree # $nix-tree .#darwinConfigurations.macos.system
    alejandra
    nh
    home-manager

    # testing
    gemini-cli-bin
    tenv
  ];

  linuxOnlyPackages = with pkgs; [
    # Core unix tools
    pciutils
    inotify-tools
    libnotify
    tuigreet

    # Media and design tools
    fontconfig
    font-manager

    # Pulseaudio
    pavucontrol

    wl-clipboard
    cliphist

    rofi
    rofi-calc

    # xdg bits
    xdg-utils
    xdg-user-dirs
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];

  darwinOnlyPackages = with pkgs; [
    gnugrep
  ];
in
{
  home.packages =
    commonPackages
    ++ (if pkgs.stdenv.isLinux then linuxOnlyPackages else [ ])
    ++ (if pkgs.stdenv.isDarwin then darwinOnlyPackages else [ ]);
}
