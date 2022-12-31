local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";

local kustomization = wirywolf.kustomization.new;

function(mode='test') [
  kustomization({
    metadata: {
      name: "infra-postgresql",
      namespace: vars.flux.namespace,
    },
    spec: {
      dependsOn: [{
        name: "infra-controllers"
      }, {
        name: "infra-configs-metallb"
      }],
      interval: "10m",
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./fluxcd/manifests/%s/infrastructure/postgresql" % mode,
      prune: true,
      wait: true,
    }
  })
]
