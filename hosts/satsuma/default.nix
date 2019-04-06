{ config, pkgs, user, hostname, ... }:

{
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
      root = "/var/www/ircsitz";
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
  services.postgresql.package = pkgs.postgresql100;

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
}
