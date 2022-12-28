local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';

function(mode) [
  wirywolf.helmRepository.new("vault-config-operator", "https://redhat-cop.github.io/vault-config-operator"),
  wirywolf.helmRelease.new({
    name: "vault-config-operator",
    spec: {
      targetNamespace: vars.vault.namespace,
      interval: "30m",
      releaseName: "vault-config-operator",
      chart: {
        spec: {
          chart: "vault-config-operator",
          version: "0.8.4",
          sourceRef: {
            kind: "HelmRepository",
            name: "vault-config-operator",
            namespace: vars.flux.namespace,
          },
          interval: "12h",
        },
      },
      values: {
        env: [{
          name: "VAULT_ADDR",
          value: wirywolf.get_vault_address(mode)
        }]
      },
    }
  })
]
