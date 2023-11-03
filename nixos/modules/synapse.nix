{ pkgs, ... }: {
  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "bukn.uk";

      url_preview_enabled = false;
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

  # TODO: Put it in individual config
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";

      CREATE ROLE "gitea" WITH LOGIN PASSWORD 'gitea';
      CREATE DATABASE "gitea" WITH OWNER "gitea"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
  };
}
