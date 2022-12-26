local vars = import "variables.libsonnet";

function(mode='test') [{
  apiVersion: "source.toolkit.fluxcd.io/v1beta2",
  kind: "HelmRepository",
  metadata: {
    name: "traefik",
    namespace: vars.flux.namespace,
  },
  spec: {
    interval: "24h",
    url: "https://helm.traefik.io/traefik"
  }
}, {
  apiVersion: "helm.toolkit.fluxcd.io/v2beta1",
  kind: "HelmRelease",
  metadata: {
    name: "traefik",
    namespace: vars.flux.namespace,
  },
  spec: {
    targetNamespace: vars.traefik.namespace,
    dependsOn: [
      {name: "metallb"},
    ],
    interval: "30m",
    install: {
      createNamespace: true,
    },
    releaseName: "traefik",
    chart: {
      spec: {
        chart: "traefik",
        version: "20.8.0",
        sourceRef: {
          kind: "HelmRepository",
          name: "traefik",
          namespace: vars.flux.namespace,
        },
        interval: "12h",
      },
    },
    values: {
      service: {
        ipFamilyPolicy: "PreferDualStack",
        spec: {
          loadBalancerIP: if mode == 'test' then vars.traefik.testLoadBalancerIP else vars.loadBalancerIP,
        },
      },
      rbac: {
        enabled: true,
      },
      ports: {
        web: {
          redirectTo: "websecure",
        },
        websecure: {
          tls: {
            enabled: true,
          },
        },
      },
      podAnnotations: {
        "prometheus.io/port": 8082,
        "prometheus.io/scrape": true,
      },
      providers: {
        kubernetesIngress: {
          publishedService: {
            enabled: true,
          },
        },
      },
      priorityClassName: "system-cluster-critical",
      tolerations: [{
        key: "CriticalAddonsOnly",
        operator: "Exists",
      }, {
        key: "node-role.kubernetes.io/control-plane",
        operator: "Exists",
        effect: "NoSchedule",
      }, {
        key: "node-role.kubernetes.io/master",
        operator: "Exists",
        effect: "NoSchedule",
      }],
    },
  },
}]
