{ config, lib, ... }:

let
  cfg = config.networking.fwrouter;
in
{
  options = {
    networking.fwrouter = with lib; {
      enable = mkEnableOption (mdDoc "Route specific traffic to other tunnel");
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      proxy-definition-tcp = { };
      proxy-definition-chained-tcp = { };
      proxy-definition-udp = { };
      proxy-definition-chained-udp = { };

      proxy-definition-tcp-backup = { };
      proxy-definition-chained-tcp-backup = { };
      proxy-definition-udp-backup = { };
      proxy-definition-chained-udp-backup = { };

      proxy-definition-udp-megatraffic = { };
      megatraffic-website-definition = { };
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

        dial_mode: domain
      }

      node {
        tcp: '${config.sops.placeholder."proxy-definition-tcp"}'
        chained-tcp: '${config.sops.placeholder."proxy-definition-chained-tcp"}'
        udp: '${config.sops.placeholder."proxy-definition-udp"}'
        chained-udp: '${config.sops.placeholder."proxy-definition-chained-udp"}'

        tcp-backup: '${config.sops.placeholder."proxy-definition-tcp-backup"}'
        chained-tcp-backup: '${config.sops.placeholder."proxy-definition-chained-tcp-backup"}'
        udp-backup: '${config.sops.placeholder."proxy-definition-udp-backup"}'
        chained-udp-backup: '${config.sops.placeholder."proxy-definition-chained-udp-backup"}'

        udp-megatraffic: '${config.sops.placeholder."proxy-definition-udp-megatraffic"}'
      }

      dns {
        upstream {
          whatever: 'udp+tcp://223.5.5.5:53'
          adguardiodns: 'udp://127.0.0.1:53215'
        }
        routing {
          request {
            qname(geosite:cn) -> whatever
            fallback: adguardiodns
          }
        }
      }

      group {
        normal-network {
          filter: name(tcp, udp)
          policy: min_moving_avg
        }

        campus-network {
          filter: name(tcp, chained-tcp, udp, chained-udp)
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

        megatraffic-network {
          filter: name(udp-megatraffic)
          policy: fixed(0)
        }
      }

      routing {
        domain(geosite:category-ads-all) -> block
        domain(keyword: stun) -> block

        domain(location.services.mozilla.com) -> direct
        domain(gis.gnome.org) -> direct
        pname(NetworkManager) -> direct
        pname(chromium) -> direct
        dport(52443) -> direct

        dip(224.0.0.0/3, 'ff00::/8') -> direct

        dip(geoip:private) -> direct
        dip(geoip:cn) -> direct
        domain(geosite:cn) -> direct

        domain(${config.sops.placeholder."megatraffic-website-definition"}) -> megatraffic-network
        pname(aria2c) -> megatraffic-network

        fallback: campus-network
      }
    '';

    services.dae = {
      enable = true;
      configFile = config.sops.templates."config.dae".path;
    };

    # Served as DNS-over-HTTPS server as dae does not support it for now
    services.smartdns = {
      enable = true;
      settings = {
        bind = [":53215"];
        server = "1.1.1.1 -bootstrap-dns";
        force-AAAA-SOA = "yes";
        server-https = [
          "https://94.140.14.140/dns-query"
          "https://94.140.14.141/dns-query"
        ];
      };
    };
  };
}
