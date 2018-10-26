{ config, pkgs, ... }:

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
  services.nginx.virtualHosts."player.fruitiex.org" = {
    locations."/" = {
      proxyPass = "http://localhost:8087";
      proxyWebsockets = true;
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
          labels.alias = "rasse-win10";
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
    after = [ "network.target" ];
    description = "Start controlling lights with lightctl-koa";
    path = [
      pkgs.bash
      pkgs.nodejs-10_x
    ];
    serviceConfig = {
      Type = "simple";
      User = "rasse";
      Restart = "on-failure";
      WorkingDirectory = "/home/rasse/src/lightctl-koa";
      ExecStart = "${pkgs.nodejs-10_x}/bin/npm run start:release";
    };
  };

  # tg-triviabot
  systemd.services.triviabot = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "mongodb.service" ];
    description = "Launch tg-triviabot";
    path = [
      pkgs.bash
      pkgs.nodejs-10_x
    ];
    serviceConfig = {
      Type = "simple";
      User = "rasse";
      Restart = "on-failure";
      WorkingDirectory = "/home/rasse/src/tg-triviabot";
      ExecStart = "${pkgs.nodejs-10_x}/bin/npm run start";
    };
  };
}
