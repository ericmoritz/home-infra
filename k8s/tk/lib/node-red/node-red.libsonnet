local k = import 'k.libsonnet';
(import "storage/storage.libsonnet") +
(import "ksonnet-util/kausal.libsonnet") +
{
  _config+:: {
    nodeRed: {
      name: 'node-red',
      port: 1880,
      hostname: 'node-red.home',
    }
  },
  _images+:: {
    nodeRed: {
      nodeRed: 'nodered/node-red:1.3.5-12-minimal-arm32v7'
    }
  },

  local c = $._config.nodeRed,
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

  nodeRed: {
    deployment:
      deployment.new(c.name, replicas=1,
        containers=[
          container.new("node-red", $._images.nodeRed.nodeRed)
          + container.withEnvMap({
            "TZ": "America/New_York",
          })
          + container.withVolumeMounts([
            {mountPath: "/data", name: c.name},

          ])
          + container.withPorts([
            containerPort.new("http", c.port),
          ]),
        ])
    + deployment.mixin.spec.template.spec.withVolumes([
      {
        name: c.name,
        persistentVolumeClaim: {
           claimName: "node-red",
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
            httpIngressPath.mixin.backend.withServicePort('node-red-http')
          ),
      )
  }
  + $.homeInfra.nasPVPair("node-red")
  ,
}
