{ config, ... }:
let
  forwardHosts = [
    { name = "chat"; port = 8448; }
    { name = "gitea"; port = 3001; }
    { name = "pb"; port = 36721; }
    { name = "telemetry"; port = 3000; }
    { name = "cloud"; port = 8088; }
    { name = "webdav"; port = 46732; }
    { name = "send"; port = 1443; }
    { name = "a"; port = 47192; }
  ];
in
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.caddy = {
    enable = true;

    virtualHosts = (builtins.listToAttrs
      (
        builtins.concatLists (
          map
            (x: [
              {
                name = "${x.name}.bukn.uk";
                value = {
                  extraConfig = ''
                    tls me@${x.name}.bukn.uk
                    header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

                    reverse_proxy localhost:${builtins.toString (x.port)}
                  '';
                };
              }
            ])
            forwardHosts)) //
    {
      "bukn.uk".extraConfig = ''
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
    } //
    {
      "wiki.bukn.uk".extraConfig = ''
        tls me@wiki.bukn.uk
        header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

        reverse_proxy /sitemap.xml localhost:3012
        reverse_proxy localhost:46178
      '';
    } //
    {
      "authentik.bukn.uk".extraConfig = ''
        tls me@authentik.bukn.uk
        header / Strict-Transport-Security "max-age=63072000;includeSubDomains;preload"

        reverse_proxy https://localhost:9443 {
          transport http {
        		tls_insecure_skip_verify
        	}
        }
      '';
    });
  };
}
