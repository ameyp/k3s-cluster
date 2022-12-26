local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local vars = import "variables.libsonnet";

function(mode='test') [{
  apiVersion: "source.toolkit.fluxcd.io/v1beta2",
  kind: "HelmRepository",
  metadata: {
    name: "kubernetes-reflector",
    namespace: vars.flux.namespace,
  },
  spec: {
    interval: "24h",
    url: "https://emberstack.github.io/helm-charts"
  }
}, {
  apiVersion: "helm.toolkit.fluxcd.io/v2beta1",
  kind: "HelmRelease",
  metadata: {
    name: "kubernetes-reflector",
    namespace: vars.flux.namespace,
  },
  spec: {
    targetNamespace: vars.kubernetes_reflector.namespace,
    interval: "30m",
    install: {
      createNamespace: true,
    },
    releaseName: "kubernetes-reflector",
    chart: {
      spec: {
        chart: "reflector",
        version: "6.1.47",
        sourceRef: {
          kind: "HelmRepository",
          name: "kubernetes-reflector",
          namespace: vars.flux.namespace,
        },
        interval: "12h",
      },
    },
  },
}]
