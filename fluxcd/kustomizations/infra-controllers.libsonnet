local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";

local kustomization = wirywolf.kustomization.new;

function(mode='test') [
  kustomization({
    metadata: {
      name: "infra-controllers",
      namespace: vars.flux.namespace,
    },
    spec: {
      interval: "10m",
      targetNamespace: vars.flux.namespace,
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/controllers" % mode,
      prune: true,
      wait: true,
    }
  })
]
