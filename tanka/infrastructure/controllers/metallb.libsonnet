local vars = import "variables.libsonnet";

function(mode='test') [{
  apiVersion: "source.toolkit.fluxcd.io/v1beta2",
  kind: "HelmRepository",
  metadata: {
    name: "metallb",
    namespace: vars.flux.namespace,
  },
  spec: {
    interval: "24h",
    url: "https://metallb.github.io/metallb"
  }
}, {
  apiVersion: "helm.toolkit.fluxcd.io/v2beta1",
  kind: "HelmRelease",
  metadata: {
    name: "metallb",
    namespace: vars.flux.namespace,
  },
  spec: {
    targetNamespace: vars.metallb.namespace,
    dependsOn: [
      {name: "prometheus-stack"},
    ],
    interval: "30m",
    install: {
      createNamespace: true,
    },
    releaseName: "metallb",
    chart: {
      spec: {
        chart: "metallb",
        version: "0.13.7",
        sourceRef: {
          kind: "HelmRepository",
          name: "metallb",
          namespace: vars.flux.namespace,
        },
        interval: "12h",
      },
    },
    values: (importstr "files/metallb/values.yaml")  % {
      prometheusLabel: vars.monitoring.prometheus_stack_name,
      prometheusNamespace: vars.monitoring.namespace,
    },
  },
}]
