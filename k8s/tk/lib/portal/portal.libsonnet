local k = import 'k.libsonnet';
(import "storage/storage.libsonnet") +
(import "ksonnet-util/kausal.libsonnet") +
{
  _config+:: {
    portal: {
      name: 'portal',
      port: 80,
      hostname: 'portal.home',
    }
  },
  _images+:: {
    portal: {
      heimdall: 'linuxserver/heimdall:2.2.2-ls70'
    }
  },

  local c = $._config.portal,
  local deployment = $.apps.v1.deployment,
  local container = $.core.v1.container,
  local service = $.core.v1.service,
  local containerPort = $.core.v1.containerPort,
  local configMap = $.core.v1.configMap,
  local volume = $.core.v1.volume,
  local ingress = k.extensions.v1beta1.ingress,
  local ingressTls = ingress.mixin.spec.tlsType,
  local ingressRule = ingress.mixin.spec.rulesType,
  local httpIngressPath = ingressRule.mixin.http.pathsType,
  local pvc = k.core.v1.persistentVolumeClaim,

  portal: {
    deployment:
      deployment.new(c.name, replicas=1,
        containers=[
          container.new("portal", $._images.portal.heimdall)
          + container.withEnvMap({
            "PUID": "1032",
            "PGID": "100",
            "TZ": "America/New_York",
          })
          + container.withVolumeMounts([
            {mountPath: "/config", name: c.name},

          ])
          + container.withPorts([
            containerPort.new("http", c.port),
          ]),
        ])
    + deployment.mixin.spec.template.spec.withVolumes([
      {
        name: c.name,
        persistentVolumeClaim: {
           claimName: "portal2",
        }
      },
    ])
    + $.util.emptyVolumeMount("logs", "/logs")
    , service: $.util.serviceFor(self.deployment)

    , ingress:
      ingress.new() +
      ingress.mixin.metadata.withName(c.name) +
      ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost(c.hostname) +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName(c.name) +
            httpIngressPath.mixin.backend.withServicePort('portal-http')
          ),
      )
    // redirect from old http://home/ URL
    , ingressRedirect:
      ingress.new() +
      ingress.mixin.metadata.withName("%s-redirect" % c.name) +
      ingress.mixin.metadata.withAnnotations({
        "traefik.ingress.kubernetes.io/redirect-permanent": "true",
        "traefik.ingress.kubernetes.io/redirect-regex": "^http://home/(.*)",
        "traefik.ingress.kubernetes.io/redirect-replacement": "http://portal.home/$1",
      }) +
      ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost("home") +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName(c.name) +
            httpIngressPath.mixin.backend.withServicePort('portal-http')
          ),
      )
  }
  + $.homeInfra.nasPVPair("portal2")
  ,
}
