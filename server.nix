{ config, pkgs, ... }:

{
  # Sync system time with NTP
  services.ntp.enable = true;

  # Enable password authentication to servers
  services.openssh.passwordAuthentication = true;

  # Audio
  hardware.pulseaudio = {
    # System-wide needed in headless usage
    systemWide = true;

    # Allow anonymous clients on the local network
    tcp.anonymousClients.allowAll = true;
    tcp.anonymousClients.allowedIpRanges = [ "127.0.0.1" "192.168.1.0/24" ];

    # Server publishes pulseaudio sink in the local network
    zeroconf.publish.enable = true;
  };
}
