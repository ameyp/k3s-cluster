local vars = import 'variables.libsonnet';

function(mode='test') {
  apiVersion: "source.toolkit.fluxcd.io/v1beta2",
  kind: "HelmRepository",
  metadata: {
    name: "hashicorp",
    namespace: vars.flux.namespace,
  },
  spec: {
    interval: "24h",
    url: "https://helm.releases.hashicorp.com"
  }
}
