local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local vars = import "variables.libsonnet";

function(mode='test') [{
  apiVersion: "source.toolkit.fluxcd.io/v1beta2",
  kind: "HelmRepository",
  metadata: {
    name: "cert-manager",
    namespace: vars.flux.namespace,
  },
  spec: {
    interval: "24h",
    url: "https://charts.jetstack.io"
  }
}, {
  apiVersion: "helm.toolkit.fluxcd.io/v2beta1",
  kind: "HelmRelease",
  metadata: {
    name: "cert-manager",
    namespace: vars.flux.namespace,
  },
  spec: {
    targetNamespace: vars.cert_manager.namespace,
    dependsOn: [
      {name: "prometheus-stack"},
      {name: "longhorn"},
      {name: "kubernetes-reflector"},
    ],
    install: {
      createNamespace: true,
    },
    interval: "30m",
    releaseName: "cert-manager",
    chart: {
      spec: {
        chart: "cert-manager",
        version: "1.10.1",
        sourceRef: {
          kind: "HelmRepository",
          name: "cert-manager",
          namespace: vars.flux.namespace,
        },
        interval: "12h",
      },
    },
    values: {
      installCRDs: "true"
    },
  },
}]
