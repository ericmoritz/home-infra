local k = import 'k.libsonnet';
(import "storage/storage.libsonnet") +
(import "ksonnet-util/kausal.libsonnet") +
{
  _config+:: {
    nodeRed: {
      name: 'mqtt',
      mqttPort: 1883,
      hostname: 'mqtt.home',
    }
  },
  _images+:: {
    nodeRed: {
      nodeRed: 'eclipse-mosquitto:2.0.11'
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
          container.new("mqtt", $._images.nodeRed.nodeRed)
          + container.withEnvMap({
            "TZ": "America/New_York",
          })
          + container.withVolumeMounts([
            {mountPath: "/mosquitto/config", subPath: "config", name: c.name},
            {mountPath: "/mosquitto/data", subPath: "data", name: c.name},
          ])
          + container.withPorts([
            containerPort.new("mqtt", c.mqttPort) + { "protocol": "TCP" },
          ]),
        ])
    + deployment.mixin.spec.template.spec.withVolumes([
      {
        name: c.name,
        persistentVolumeClaim: {
           claimName: "mqtt",
        }
      },
    ])
    + $.util.emptyVolumeMount("logs", "/mosquitto/logs")
    , service: $.util.serviceFor(self.deployment)
        + service.mixin.spec.withType("LoadBalancer")
  }
  + $.homeInfra.nasPVPair("mqtt")
}
