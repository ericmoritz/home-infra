local k = import 'k.libsonnet';
(import "ksonnet-util/kausal.libsonnet") +
{
  _config+:: {
    dl: {
      name: 'dl',
      volumeName: 'media-repo',
      sonarr: {
        hostname: 'sonarr.home',
      },
      sabnzbd: {
        hostname: 'nzb.home',
      },
    }
  },
  _images+:: {
    dl: {
      sonarr: 'linuxserver/sonarr:2.0.0.5337-ls93',
      sabnzbd: 'linuxserver/sabnzbd:latest',
    }
  },

  local c = $._config.dl,
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
          // Sonarr container
          container.new("sonarr", $._images.dl.sonarr)
          + container.withEnvMap({
            "PUID": "1032",
            "PGID": "100",
            "TZ": "America/New_York",
          })
          + container.withVolumeMounts([
            {mountPath: "/config", subPath: "sonarr-config", name: c.name},
            {mountPath: "/tv", subPath: "tv", name: c.name},
            {mountPath: "/downloads", subPath: "downloads", name: c.name},

          ])
          + container.withPorts([
            containerPort.new("http", 8989),
          ]),

          // Sabnzbd container
          container.new("sabnzbd", $._images.dl.sabnzbd)
          + container.withEnvMap({
            "PUID": "1032",
            "PGID": "100",
            "TZ": "America/New_York",
          })
          + container.withVolumeMounts([
            {mountPath: "/config", subPath: "sabnzbd-config", name: c.name},
            {mountPath: "/downloads", subPath: "downloads", name: c.name},
            {mountPath: "/incomplete-downloads", subPath: "incomplete-downloads", name: c.name},

          ])
          + container.withPorts([
            containerPort.new("http", 8080),
          ]),
        ])
    + deployment.mixin.spec.template.spec.withVolumes([
      {
        name: c.name,
        persistentVolumeClaim: {
           claimName: c.volumeName,
        }
      },
    ])
    , service: $.util.serviceFor(self.deployment)

    , sonarrIngress:
      ingress.new() +
      ingress.mixin.metadata.withName("%s-sonarr" % c.name) +
      ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost(c.sonarr.hostname) +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName(c.name) +
            httpIngressPath.mixin.backend.withServicePort('sonarr-http')
          ),
      )
    , sabnzbdIngress:
      ingress.new() +
      ingress.mixin.metadata.withName("%s-sabnzbd" % c.name) +
      ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost(c.sabnzbd.hostname) +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName(c.name) +
            httpIngressPath.mixin.backend.withServicePort('sabnzbd-http')
          ),
      )
  }
  + $.homeInfra.nasPVPair(c.volumeName)
}
