{ config, ... }: {
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.caddy = {
    enable = true;
    virtualHosts."bukn.uk".extraConfig = ''
      tls me@bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      header /.well-known/matrix/* Content-Type application/json
      header /.well-known/matrix/* Access-Control-Allow-Origin *
      respond /.well-known/matrix/server `{"m.server": "chat.bukn.uk:443"}`
      respond /.well-known/matrix/client `{"m.homeserver":{"base_url":"https://chat.bukn.uk"}}`
    '';

    virtualHosts."chat.bukn.uk".extraConfig = ''
      tls me@chat.bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      reverse_proxy localhost:8448
    '';
  };
}