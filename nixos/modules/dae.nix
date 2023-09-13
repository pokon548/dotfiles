{ config, ... }:
{
  sops.secrets = {
    proxy-definition-tcp = { };
    proxy-definition-chained-tcp = { };

    proxy-definition-tcp-backup = { };
    proxy-definition-chained-tcp-backup = { };
    proxy-definition-udp-backup = { };
    proxy-definition-chained-udp-backup = { };
  };

  sops.templates."config.dae".content = ''
    global {
      tproxy_port: 12345
      tproxy_port_protect: true
      so_mark_from_dae: 0
      log_level: info

      wan_interface: auto
      auto_config_kernel_parameter: true

      allow_insecure: false
      sniffing_timeout: 100ms
      tls_implementation: utls
      utls_imitate: chrome_auto

      dial_mode: ip
    }

    node {
      tcp: '${config.sops.placeholder."proxy-definition-tcp"}'
      chained-tcp: '${config.sops.placeholder."proxy-definition-chained-tcp"}'

      tcp-backup: '${config.sops.placeholder."proxy-definition-tcp-backup"}'
      chained-tcp-backup: '${config.sops.placeholder."proxy-definition-chained-tcp-backup"}'
      udp-backup: '${config.sops.placeholder."proxy-definition-udp-backup"}'
      chained-udp-backup: '${config.sops.placeholder."proxy-definition-chained-udp-backup"}'
    }

    dns {
      upstream {
        alidns: 'udp://127.0.0.1:53214'
        adguardiodns: 'tcp://94.140.14.140:53'
      }
      routing {
        request {
          qname(geosite:cn) -> alidns
          fallback: adguardiodns
        }
      }
    }

    group {
      normal-network {
        filter: name(tcp)
        policy: min_moving_avg
      }

      campus-network {
        filter: name(tcp, chained-tcp)
        policy: min_moving_avg
      }

      backup-normal-network {
        filter: name(tcp-backup, udp-backup)
        policy: min_moving_avg
      }

      backup-campus-network {
        filter: name(tcp-backup, chained-tcp-backup, udp-backup, chained-udp-backup)
        policy: min_moving_avg
      }
    }

    routing {
      domain(geosite:category-ads-all) -> block

      domain(location.services.mozilla.com) -> direct
      domain(gis.gnome.org) -> direct
      pname(NetworkManager) -> direct
      dport(52443) -> direct

      dip(224.0.0.0/3, 'ff00::/8') -> direct

      dip(geoip:private) -> direct
      dip(geoip:cn) -> direct
      domain(geosite:cn) -> direct

      fallback: backup-campus-network
    }
  '';

  services.dae = {
    enable = true;
    configFile = config.sops.templates."config.dae".path;
  };

  # Served as DNS-over-HTTPS server...
  services.smartdns = {
    enable = true;
    settings = {
      bind = ":53214";
      server = "223.5.5.5 -bootstrap-dns";
      server-https = [
        "https://223.5.5.5/dns-query"
        "https://1.12.12.12/dns-query"
      ];
    };
  };
}