{ pkgs, ... }: {
  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "bukn.uk";

      url_preview_enabled = true;
      max_upload_size = "100M";
      enable_registration = false;

      listeners = [
        {
          bind_addresses = [ "127.0.0.1" "::1" ];
          port = 8448;
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [{
            compress = false;
            names = [ "client" "federation" ];
          }];
        }
      ];

      registration_requires_token = true;
    };
  };

  services.postgresql = {
    enable = true;
    initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
  };
}
