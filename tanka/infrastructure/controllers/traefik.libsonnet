local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
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
    values: (importstr "files/traefik/values.yaml")  % {
      loadBalancerIP: if mode == 'test' then vars.traefik.testLoadBalancerIP else vars.loadBalancerIP,
    },
  },
}]
