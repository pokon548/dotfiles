{ ... }:
{
  services.dae = {
    enable = true;
    config = ''
      global {
        tproxy_port: 12345
        tproxy_port_protect: true
        so_mark_from_dae: 0
        log_level: info

        wan_interface: auto
        auto_config_kernel_parameter: true

        allow_insecure: false
        sniffing_timeout: 100ms
        tls_implementation: tls
        utls_imitate: chrome_auto
      }

      node {
        node1: 'socks5://localhost:2080'
      }

      dns {
        upstream {
          alidns: 'udp://dns.alidns.com:53'
          googledns: 'tcp+udp://dns.google:53'
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
        pname(NetworkManager) -> direct
        dport(52443) -> direct
        dip(224.0.0.0/3, 'ff00::/8') -> direct

        dip(geoip:private) -> direct
        dip(geoip:cn) -> direct
        domain(geosite:cn) -> direct

        domain(location.services.mozilla.com) -> direct

        fallback: my_group
      }
    '';
  };
}
