{ config, pkgs, lib, user, ... }:

{
  # virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  # PostgreSQL
  # services.postgresql = {
  #   enable = true;
  #   package = pkgs.postgresql_11;
  #   authentication = lib.mkForce ''
  #     # TYPE  DATABASE        USER            ADDRESS                 METHOD
  #     local   all             all                                     trust
  #     host    all             all             127.0.0.1/32            trust
  #     host    all             all             ::1/128                 trust
  #   '';
  # };
}
