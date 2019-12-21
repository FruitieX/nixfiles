{ config, pkgs, user, hostname, ... }:

{
  # Update Intel CPU microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Spin down idle HDD:s
  systemd.services.hd-idle = {
    description = "Spin down HDD after idle period";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 60";
    };
  };

  # Audio
  hardware.pulseaudio = {
    # System-wide needed in headless usage
    systemWide = true;

    # Allow anonymous clients on the local network
    tcp.anonymousClients.allowAll = true;
    tcp.anonymousClients.allowedIpRanges = [ "127.0.0.1" "192.168.1.0/24" ];

    # Server publishes pulseaudio sink in the local network
    zeroconf.publish.enable = true;

    # Play multicast RTP streams on local network
    extraConfig = ''
      load-module module-rtp-recv
    '';
  };

  # Samba
  users.extraUsers.julle = {
    password = "change-me";
    isNormalUser = true;
  };

  services.samba = {
    enable = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${hostname}
      netbios name = ${hostname}
    '';
    shares = {
      media = {
        path = "/media";
        browseable = "yes";
        writable = "yes";
      };
      julle = {
        path = "/mnt/home/julle";
        browseable = "yes";
        writable = "yes";
      };
    };
  };

  # Sync system time with NTP
  services.ntp.enable = true;

  # Enable password authentication to satsuma
  services.openssh.passwordAuthentication = true;
  programs.ssh.extraConfig = ''
    AcceptEnv LANG LC_* TMUX
  '';

  # Nginx
  services.nginx.enable = true;
  services.nginx.virtualHosts."fruitiex.org" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      root = "/var/www/fruitiex";
    };
  };
  services.nginx.virtualHosts."ircsitz.fruitiex.org" = {
    locations."/api" = {
      proxyPass = "http://localhost:3000";
    };
    locations."/socket.io" = {
      proxyPass = "http://localhost:3000";
      proxyWebsockets = true;
    };
    locations."/" = {
      proxyPass = "http://localhost:9000";
    };
  };
  services.nginx.virtualHosts."192.168.1.101" = {
    locations."/api" = {
      proxyPass = "http://localhost:5678";
    };
  };

  # Letsencrypt
  security.acme.certs."fruitiex.org" = {
    email = "fruitiex@gmail.com";
  };

  # Plex media server
  services.plex.enable = true;

  # PostgreSQL
  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql_10;

  # MongoDB
  services.mongodb.enable = true;
  environment.systemPackages = with pkgs; [ mongodb-tools ];

  # Prometheus scrapes Windows machine
  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [
        {
          targets = [ "localhost:9100" ];
          labels.alias = "satsuma";
        }
        {
          targets = [ "192.168.1.234:9182" ];
          labels.alias = "watermelon";
        }
      ];
    }
  ];

  # Make Grafana accessible to local network
  services.grafana.addr = "0.0.0.0";

  # TODO: package below nodejs properly with e.g. node2nix

  # lightctl service
  systemd.services.lightctl = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    description = "Start controlling lights with lightctl-koa";
    path = [
      pkgs.bash
      pkgs.nodejs-10_x
    ];
    serviceConfig = {
      Type = "simple";
      User = user;
      Restart = "on-failure";
      WorkingDirectory = "/home/${user}/src/lightctl-koa";
      ExecStart = "${pkgs.nodejs-10_x}/bin/npm run start:release";
    };
  };

  # tg-triviabot
  systemd.services.triviabot = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "mongodb.service" ];
    requires = [ "network-online.target" ];
    description = "Launch tg-triviabot";
    path = [
      pkgs.bash
      pkgs.nodejs-10_x
    ];
    serviceConfig = {
      Type = "simple";
      User = user;
      Restart = "on-failure";
      WorkingDirectory = "/home/${user}/src/tg-triviabot";
      ExecStart = "${pkgs.nodejs-10_x}/bin/npm run start";
    };
  };

  # add-bot
  systemd.services.add-bot = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    description = "Launch add-bot";
    path = [
      pkgs.bash
      pkgs.nodejs-10_x
    ];
    serviceConfig = {
      Type = "simple";
      User = user;
      Restart = "on-failure";
      WorkingDirectory = "/home/${user}/src/add-bot";
      ExecStart = "${pkgs.nodejs-10_x}/bin/npm run start";
    };
  };

  #systemd.services.csgo-comp = {
  #  wantedBy = [ "multi-user.target" ];
  #  after = [ "network-online.target" ];
  #  requires = [ "network-online.target" ];
  #  description = "Launch csgo comp server";
  #  path = [
  #    pkgs.steamcmd
  #    (import ../../fhs pkgs)
  #  ];
  #  serviceConfig = {
  #    Type = "simple";
  #    User = user;
  #    Restart = "on-failure";
  #    WorkingDirectory = "/home/${user}/csgo-comp";
  #    ExecStart = "${pkgs.bash}/bin/bash /home/${user}/csgo-comp.sh";
  #  };
  #};

  systemd.services.csgo-smokes = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    description = "Launch csgo smokes server";
    path = [
      pkgs.steamcmd
      (import ../../fhs pkgs)
    ];
    serviceConfig = {
      Type = "simple";
      User = user;
      Restart = "on-failure";
      WorkingDirectory = "/home/${user}/csgo-smokes";
      ExecStart = "${pkgs.bash}/bin/bash /home/${user}/csgo-smokes.sh";
    };
  };

  users.extraUsers.code = {
    isNormalUser = true;
    extraGroups = [ "docker" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxHyNeiwAzZoExz8iOWkxYmb/3xsN9QVwp/R0/SRUZlFQRPoXk4Ncwkt/U8aiSpm0XmrG1WWGYO9lf5UzAPX8LyHOfjaOyvCTok7RhyMSYZ1cBOJsEQ8MfMRKqjZ0vBaLjRDZoFBERT+/VBfazjTUB1Fv8dGHS8PLvdhMly2VinsSGTc/tApdigP61SJeLmo7NoDavBqTKHx1efJRAw4dRKilhl8fOvAsBCuOn9UzBdZAYX4WTpHvlZGFnkRvLteeAmHGuFPUq8ofc3X4HZfukIz1/l5Ya8l5srHAQEsSpKGcG7EuRHBz+cwEulfjDKlVyFK1Jx7UwJHFGKENtFbST rasse" ];
  };
}
