local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";

local kustomization = wirywolf.kustomization.new;

function(mode='test') [
  kustomization({
    metadata: {
      name: "infra-vault-config-operator",
      namespace: vars.flux.namespace,
    },
    spec: {
      dependsOn: [{
        name: "infra-configs-vault-initializers"
      }],
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/vault-config-operator/kustomizations" % mode,
      prune: true,
      wait: true,
    }
  })
]
