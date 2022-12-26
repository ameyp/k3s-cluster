local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';
local secretName = 'alert-manager-config';

function(mode='test') [
  wirywolf.secret.new({
    name: secretName,
    data: {
      "alertmanager.yaml": std.base64(importstr "files/prometheus/alertmanager.conf")
    }
  }), {
    apiVersion: "source.toolkit.fluxcd.io/v1beta2",
    kind: "HelmRepository",
    metadata: {
      name: "prometheus",
      namespace: vars.flux.namespace,
    },
    spec: {
      interval: "24h",
      url: "https://prometheus-community.github.io/helm-charts"
    }
  }, {
    apiVersion: "helm.toolkit.fluxcd.io/v2beta1",
    kind: "HelmRelease",
    metadata: {
      name: "prometheus-stack",
      namespace: vars.flux.namespace,
    },
    spec: {
      targetNamespace: vars.monitoring.namespace,
      interval: "30m",
      install: {
        createNamespace: true,
      },
      chart: {
        spec: {
          chart: "kube-prometheus-stack",
          version: "43.1.0",
          sourceRef: {
            kind: "HelmRepository",
            name: "prometheus",
            namespace: vars.flux.namespace,
          },
          interval: "12h",
        },
      },
      values: (importstr "files/prometheus/values.yaml") % {
        controller_ip: vars.cluster.controller_ip,
        config_secret: "",
        vault_address: wirywolf.get_endpoint(vars.vault.main.ingress.subdomain, mode),
      },
    },
  },
]
