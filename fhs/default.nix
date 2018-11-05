{ pkgs, ... }: with pkgs;

pkgs.buildFHSUserEnv {
  name = "fhs";

  # Make sure system tools are available in FHS env
  targetPkgs = pkgs: with pkgs; [
    systemToolsEnv
    unstable-small.yarn
    unstable-small.nodejs

    # Needed by cypress
    chromium
    alsaLib
    gtk3
    at_spi2_atk
  ];

  # Most of these are from pkgs/games/steam/chrootenv.nix
  # TODO: import them from there instead of maintaining this list
  multiPkgs = pkgs: with pkgs; [
    xorg.libXcomposite
    xorg.libXtst
    xorg.libXrandr
    xorg.libXext
    xorg.libX11
    xorg.libXfixes
    libGL

    # Not formally in runtime but needed by some games
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-ugly
    libdrm
    mono
    xorg.xkeyboardconfig
    xorg.libpciaccess

    # Required
    glib
    gtk2
    bzip2
    zlib
    gdk_pixbuf

    # Without these it silently fails
    xorg.libXinerama
    xorg.libXdamage
    xorg.libXcursor
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXxf86vm
    xorg.libXi
    xorg.libSM
    xorg.libICE
    gnome2.GConf
    freetype
    (curl.override { gnutlsSupport = true; sslSupport = false; })
    nspr
    nss
    fontconfig
    cairo
    pango
    expat
    dbus
    cups
    libcap
    SDL2
    libusb1
    dbus-glib
    libav
    atk
    # Only libraries are needed from those two
    libudev0-shim
    networkmanager098

    # Verified games requirements
    xorg.libXt
    xorg.libXmu
    xorg.libxcb
    libGLU
    libuuid
    libogg
    libvorbis
    SDL
    SDL2_image
    glew110
    openssl
    libidn
    tbb
    wayland
    mesa_noglu
    libxkbcommon

    # Other things from runtime
    flac
    freeglut
    libjpeg
    libpng12
    libsamplerate
    libmikmod
    libtheora
    libtiff
    pixman
    speex
    SDL_image
    SDL_ttf
    SDL_mixer
    SDL2_ttf
    SDL2_mixer
    gstreamer
    gst-plugins-base
    libappindicator-gtk2
    libcaca
    libcanberra
    libgcrypt
    libvpx
    librsvg
    xorg.libXft
    libvdpau
  ];
  runScript = "$SHELL";
}
