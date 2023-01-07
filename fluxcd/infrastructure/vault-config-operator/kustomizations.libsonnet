local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";
local kustomization = wirywolf.kustomization.new;

function(mode) {
  "kustomizations/configuration.yaml": kustomization({
    metadata: {
      name: "vault-config-operator-configuration",
      namespace: vars.flux.namespace,
    },
    spec: {
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/vault-config-operator/configuration" % mode,
      prune: true,
      wait: true,
    }
  }),
  "kustomizations/main.yaml": kustomization({
    metadata: {
      name: "vault-config-operator",
      namespace: vars.flux.namespace,
    },
    spec: {
      dependsOn: [{
        name: "vault-config-operator-configuration"
      }],
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/vault-config-operator/main" % mode,
      prune: true,
      wait: true,
    }
  }),
}
