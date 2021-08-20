local k = import 'k.libsonnet';
(import "storage/storage.libsonnet") +
(import "ksonnet-util/kausal.libsonnet") +
{
  _config+:: {
    grafanad: {
      name: 'grafana',
      port: 3000,
      hostname: 'grafana.home',
    }
  },
  _images+:: {
    grafanad: {
      grafanad: 'grafana/grafana:8.1.2',
    }
  },

  local c = $._config.grafanad,
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

  grafanad: {
    deployment:
      deployment.new(c.name, replicas=1,
        containers=[
          container.new("grafana", $._images.grafanad.grafanad)
          + container.withEnvMap({
            "TZ": "America/New_York",
          })
          + container.withVolumeMounts([
            // {mountPath: "/etc/grafana", subPath: "etc", name: c.name},
            {mountPath: "/var/lib/grafana", subPath: "data", name: c.name},
            {mountPath: "/var/share/grafana", subPath: "home", name: c.name},
            {mountPath: "/var/log/grafana", subPath: "log", name: c.name},
          ])
          + container.withPorts([
            containerPort.new("http", c.port),
          ]),
        ])
    + deployment.mixin.spec.template.spec.withVolumes([
      {
        name: c.name,
        persistentVolumeClaim: {
           claimName: "grafana",
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
            httpIngressPath.mixin.backend.withServicePort('grafana-http')
          ),
      )
  }
  + $.homeInfra.nasPVPair("grafana")
  ,
}
