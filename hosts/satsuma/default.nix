{ config, pkgs, ... }:

{
  imports =
    [
      ../../server.nix
    ];

  environment.systemPackages = with pkgs; [
    mongodb-tools
  ];

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
}
