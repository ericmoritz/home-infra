local k = import 'k.libsonnet';
(import "storage/storage.libsonnet") +
(import "ksonnet-util/kausal.libsonnet") +
{
  _config+:: {
    ll: {
      name: 'lazylibrarian',
      shortName: 'll',
      port: 5299,
      hostname: 'll.home',
    }
  },
  _images+:: {
    lazylibrarian: 'linuxserver/lazylibrarian:latest',
  },

  local c = $._config.ll,
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

  ll: {
    deployment:
      deployment.new(c.name, replicas=1,
        containers=[
          container.new(c.shortName, $._images.lazylibrarian)
          + container.withEnvMap({
            "PUID": "1032",
            "PGID": "100",
            "TZ": "America/New_York",
          })
          + container.withVolumeMounts([
            {mountPath: "/config", subPath: "config", name: c.name},
            {mountPath: "/books", subPath: "books", name: c.name},
            {mountPath: "/import", subPath: "import", name: c.name},
            {mountPath: "/downloads", subPath: "downloads", name: c.name},

          ])
          + container.withPorts([
            containerPort.new("http", c.port),
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
            httpIngressPath.mixin.backend.withServicePort('%s-http' % c.shortName)
          ),
      ),
  }
  + $.homeInfra.nasPVPair(c.name)
  ,
}
