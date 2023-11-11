{ config, lib, pkgs, ... }: {
  sops = {
    defaultSopsFile = lib.mkDefault ../../../secrets/hetzner.yaml;
    secrets = {
      "synapse/oidc/client-id" = { };
      "synapse/oidc/client-secret" = { };
      "synapse/registration-shared-secret" = { 
        owner = "matrix-synapse";
      };
    };
  };

  sops.templates."oidc-config.yaml" = {
    content = ''
      oidc_providers:
        - idp_id: authentik
          idp_name: authentik
          discover: true
          issuer: "https://authentik.bukn.uk/application/o/matrix-slug/"
          client_id: "${config.sops.placeholder."synapse/oidc/client-id"}"
          client_secret: "${config.sops.placeholder."synapse/oidc/client-secret"}"
          scopes:
            - "openid"
            - "profile"
            - "email"
          user_mapping_provider:
            config:
              localpart_template: "{{ user.preferred_username }}"
              display_name_template: "{{ user.preferred_username|capitalize }}"
    '';
    owner = "matrix-synapse";
  };

  services.matrix-synapse = {
    enable = true;
    extras = [
      "systemd"
      "postgres"
      "url-preview"
      "user-search"

      "oidc"
    ];
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
      registration_shared_secret_path = config.sops.secrets."synapse/registration-shared-secret".path;
    };

    extraConfigFiles = [
      config.sops.templates."oidc-config.yaml".path
    ];
  };

  # TODO: Put it in individual config
  services.postgresql = {
    enable = true;
    package = lib.mkForce pkgs.postgresql_14;
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
