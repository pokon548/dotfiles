{ config, ... }: {
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.caddy = {
    enable = true;
    virtualHosts."www.bukn.uk".extraConfig = ''
      tls me@www.bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      redir https://bukn.uk{uri}
    '';

    virtualHosts."bukn.uk".extraConfig = ''
      tls me@bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      header /.well-known/matrix/* Content-Type application/json
      header /.well-known/matrix/* Access-Control-Allow-Origin *
      respond /.well-known/matrix/server `{"m.server": "chat.bukn.uk:443"}`
      respond /.well-known/matrix/client `{"m.homeserver":{"base_url":"https://chat.bukn.uk"}}`

      handle_path /_matrix/* {
        rewrite * /_matrix{uri}
	      reverse_proxy localhost:8448
      }

      handle_path /_synapse/* {
        rewrite * /_synapse{uri}
	      reverse_proxy localhost:8448
      }
    '';

    virtualHosts."chat.bukn.uk".extraConfig = ''
      tls me@chat.bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      reverse_proxy localhost:8448
    '';

    virtualHosts."gitea.bukn.uk".extraConfig = ''
      tls me@gitea.bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      reverse_proxy localhost:3001
    '';

    virtualHosts."pb.bukn.uk".extraConfig = ''
      tls me@pb.bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      reverse_proxy localhost:36721
    '';

    virtualHosts."wiki.bukn.uk".extraConfig = ''
      tls me@wiki.bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      reverse_proxy /sitemap.xml localhost:3012
      reverse_proxy localhost:46178
    '';

    virtualHosts."telemetry.bukn.uk".extraConfig = ''
      tls me@telemetry.bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      reverse_proxy localhost:3000
    '';

    virtualHosts."authentik.bukn.uk".extraConfig = ''
      tls me@authentik.bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      reverse_proxy https://localhost:9443 {
        transport http {
			    tls_insecure_skip_verify
		    }
      }
    '';

    virtualHosts."filestash.bukn.uk".extraConfig = ''
      tls me@authentik.bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      reverse_proxy http://localhost:8334
    '';

    virtualHosts."kosync.bukn.uk".extraConfig = ''
      tls me@kosync.bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      reverse_proxy http://localhost:7200
    '';
  };
}
