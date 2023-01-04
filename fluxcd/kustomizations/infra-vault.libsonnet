local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";

local kustomization = wirywolf.kustomization.new;

function(mode='test') [
  kustomization({
    metadata: {
      name: "infra-vault",
      namespace: vars.flux.namespace,
    },
    spec: {
      dependsOn: [{
        name: "infra-configs-certs"
      }, {
        name: "infra-configs-metallb"
      }, {
        name: "infra-configs-longhorn"
      }, {
        name: "infra-configs-vault"
      }],
      interval: "10m",
      targetNamespace: vars.flux.namespace,
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/vault" % mode,
      prune: true,
      wait: true,
    }
  })
]
