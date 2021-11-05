local k = import 'k.libsonnet';
(import "ksonnet-util/kausal.libsonnet") +
{
  _config+:: {
    dl: {
      name: 'dl',
      volumeName: 'media-repo',
      radarr: {
        hostname: 'radarr.home',
      },
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
      sonarr: 'linuxserver/sonarr:3.0.6.1342-ls127',
      sabnzbd: 'linuxserver/sabnzbd:3.4.2',
      radarr: 'linuxserver/radarr:3.2.2.5080-ls119',
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

  dl: {
    deployment:
      deployment.new(c.name, replicas=1,
        containers=[

          // Radarr container
          container.new("radarr", $._images.dl.radarr)
          + container.withEnvMap({
            "PUID": "1032",
            "PGID": "100",
            "TZ": "America/New_York",
          })
          + container.withVolumeMounts([
            {mountPath: "/config", subPath: "radarr-config", name: c.name},
            {mountPath: "/movies", subPath: "movies", name: c.name},
            {mountPath: "/downloads", subPath: "downloads", name: c.name},

          ])
          + container.withPorts([
            containerPort.new("http", 7878),
          ]),

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
          // Note, after the container boots, you well need to set the `host_whitelist` to the hostname and restart the Pod
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

    , radarrIngress:
      ingress.new() +
      ingress.mixin.metadata.withName("%s-radarr" % c.name) +
      ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost(c.radarr.hostname) +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName(c.name) +
            httpIngressPath.mixin.backend.withServicePort('radarr-http')
          ),
      )

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
