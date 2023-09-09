{ config, ... }:
{
  sops.secrets.proxy-definition = { };

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
        node1: '${config.sops.placeholder."proxy-definition"}'
      }

      dns {
        ipversion_prefer: 4

        upstream {
          alidns: 'udp://223.5.5.5:53'
          googledns: 'tcp+udp://94.140.14.140:53'
        }
        routing {
          request {
            qname(geosite:cn) -> alidns
            fallback: googledns
          }
        }
      }

      group {
        my_group {
          policy: min_moving_avg
        }
      }

      routing {
        domain(location.services.mozilla.com) -> direct
        domain(gis.gnome.org) -> direct
        pname(NetworkManager) -> direct
        dport(52443) -> direct
        dip(224.0.0.0/3, 'ff00::/8') -> direct

        dip(geoip:private) -> direct
        dip(geoip:cn) -> direct
        domain(geosite:cn) -> direct

        fallback: my_group
      }
  '';

  services.dae = {
    enable = true;
    configFile = config.sops.templates."config.dae".path;
  };
}