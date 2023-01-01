local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";
local kustomization = wirywolf.kustomization.new;

function(mode) [
  kustomization({
    metadata: {
      name: "infra-vault-data",
      namespace: vars.flux.namespace,
    },
    spec: {
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/vault-data" % mode,
      prune: true,
      wait: true,
      dependsOn: [{
        name: "infra-vault-config-operator",
      }, {
        name: "infra-databases",
      }]
    }
  })
]
