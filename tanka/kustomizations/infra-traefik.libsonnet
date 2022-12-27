local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";

local kustomization = wirywolf.kustomization.new;

function(mode='test') [
  kustomization({
    metadata: {
      name: "infra-traefik",
      namespace: vars.flux.namespace,
    },
    spec: {
      dependsOn: [{
        name: "infra-controllers"
      }, {
        name: "infra-configs-metallb"
      }],
      interval: "10m",
      targetNamespace: vars.flux.namespace,
      sourceRef: {
        kind: "GitRepository",
        name: "k3s-cluster-deploy",
      },
      path: "./tanka/manifests/%s/infrastructure/traefik" % mode,
      prune: true,
      wait: true,
    }
  })
]
