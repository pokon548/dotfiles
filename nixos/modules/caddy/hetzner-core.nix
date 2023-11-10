{ config, ... }: {
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.caddy = {
    enable = true;

    virtualHosts."authentik.bukn.uk".extraConfig = ''
      tls me@authentik.bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      reverse_proxy https://localhost:9443 {
        transport http {
			    tls_insecure_skip_verify
		    }
      }
    '';

    virtualHosts."uptime.bukn.uk".extraConfig = ''
      tls me@uptime.bukn.uk
      header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

      reverse_proxy http://localhost:4000
    '';
  };
}
