local k = import 'k.libsonnet';
(import "storage/storage.libsonnet") +
(import "ksonnet-util/kausal.libsonnet") +
{
  _config+:: {
    pihole: {
      name: 'pihole',
      hostname: 'pihole.home',
      dnsPort: 5353,
      webPort: 8080,
    }
  },
  _images+:: {
    pihole: 'pihole/pihole:v5.0',
  },

  local c = $._config.pihole,
  local deployment = $.apps.v1.deployment,
  local container = $.core.v1.container,
  local containerPort = $.core.v1.containerPort,
  local service = $.core.v1.service,
  local servicePort = service.mixin.spec.portsType,
  local ingress = k.extensions.v1beta1.ingress,
  local ingressRule = ingress.mixin.spec.rulesType,
  local httpIngressPath = ingressRule.mixin.http.pathsType,
  local pvc = k.core.v1.persistentVolumeClaim,

  pihole: {
    deployment:
      deployment.new(c.name, replicas=1,
        containers=[
          container.new(c.name, $._images.pihole)
          + container.withEnvMap({
            "TZ": "America/New_York",
            "WEB_PORT": "%d" % c.webPort,
            "VIRTUAL_HOST": c.hostname,
          })
          + container.withVolumeMounts([
            {mountPath: "/etc/pihole", subPath: "pihole-etc", name: c.name},
            {mountPath: "/etc/dnsmasq.d", subPath: "dnsmasq-etc", name: c.name},

          ])
          + container.withPorts([
            containerPort.new("dns-udp", 53) + { "protocol": "UDP" },
            containerPort.new("http", c.webPort),
          ]),
        ])
    + deployment.mixin.spec.template.spec.withVolumes([
      {
        name: c.name,
        persistentVolumeClaim: {
           claimName: c.name,
        }
      },
    ])
    , dnsservice:
      service.new(
        "%sdns" % c.name,
        {name: c.name},
        [
          servicePort.newNamed("pihole-dns-tcp", port=5353, targetPort='dns-udp') + servicePort.withProtocol("UDP"),
        ],
      )
      + service.mixin.spec.withType("LoadBalancer")
    , service:
      service.new(
        c.name,
        {name: c.name},
        [
          servicePort.newNamed("pihole-http", c.webPort, c.webPort) + servicePort.withProtocol("TCP"),
        ],
      )
    , ingress:
      ingress.new() +
      ingress.mixin.metadata.withName(c.name) +
      ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost(c.hostname) +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName(c.name) +
            httpIngressPath.mixin.backend.withServicePort('%s-http' % c.name)
          ),
      ),
  }
  + $.homeInfra.nasPVPair(c.name)
  ,
}
