(import "ksonnet-util/kausal.libsonnet") +
{
  _config+:: {
    dns: {
      name: 'dns',
      dnsPort: 53,
    }
  },
  _images+:: {
    dns: {
      coredns: "coredns/coredns:1.6.6",
    }
  },

  local deployment = $.apps.v1.deployment,
  local container = $.core.v1.container,
  local service = $.core.v1.service,
  local containerPort = $.core.v1.containerPort,
  local configMap = $.core.v1.configMap,
  local volume = $.core.v1.volume,
  local c = $._config.dns,

  dns: {
    deployment:
      deployment.new(c.name, replicas=1,
        containers=[
          container.new("coredns", $._images.dns.coredns)
          + {"args": ["-conf", "/etc/coredns/Corefile"]}
          + container.withPorts([
            containerPort.new("dns", c.dnsPort) + { "protocol": "UDP" },
            containerPort.new("dns-tcp", c.dnsPort) + { "protocol": "TCP" },
          ]),
        ])
      + $.util.configMapVolumeMount(self.conf, '/etc/coredns/')
    , service: $.util.serviceFor(self.deployment)

      + service.mixin.spec.withType("LoadBalancer")
    , conf: configMap.new(c.name)
    + configMap.withData({
      "home": |||
        @ IN SOA home. admin.home. (
                 2018110201  ;Serial
                 3600        ;Refresh
                 1800        ;Retry
                 604800      ;Expire
                 86400       ;Minimum TTL
        )
              IN NS home
              IN A  192.168.1.3
        * 3600 IN CNAME home.
      |||,
      "Corefile": |||
        home:53 {
          file /etc/coredns/home
        }
        .:53 {
          errors
          health
          ready
          prometheus :9153
          cache 30
          loop
          reload
          loadbalance
          forward . 8.8.8.8
        }
      |||
    })

  },
}
