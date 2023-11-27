{ config, lib, ... }: {
  sops = {
    defaultSopsFile = lib.mkForce ../../secrets/hetzner.yaml;
    secrets = {
      "geolite-key" = { };
    };
    templates = {
      "shlink-env".content = ''
        DEFAULT_DOMAIN=a.bukn.uk
        IS_HTTPS_ENABLED=false
        GEOLITE_LICENSE_KEY=${config.sops.placeholder."geolite-key"}
      '';
    };
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      shlink = {
        autoStart = true;
        image = "docker.io/shlinkio/shlink:stable";
        environmentFiles = [ config.sops.templates."shlink-env".path ];
        ports = [ "47192:8080" ];
      };
    };
  };
}
