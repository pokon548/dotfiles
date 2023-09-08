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
          adguarddns: 'tcp+udp://94.140.14.140:53'
        }
        routing {
          request {
            fallback: alidns
          }

          response {
            upstream(googledns) -> accept
            !qname(geosite:cn) && ip(geoip:private) -> googledns
            fallback: accept
          }
        }
      }

      routing {
        pname(NetworkManager) -> direct
        dip(224.0.0.0/3, 'ff00::/8') -> direct

        dip(geoip:private) -> direct
        dip(geoip:cn) -> direct
        domain(geosite:cn) -> direct

        fallback: node1
      }
    '';
  };
}
