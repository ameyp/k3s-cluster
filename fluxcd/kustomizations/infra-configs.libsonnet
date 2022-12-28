local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";

local kustomization = wirywolf.kustomization.new;
local metadata = import "./infra-configs-metadata.libsonnet";
local spec = import "./infra-configs-spec.libsonnet";

function(mode) [
  kustomization({
    metadata: metadata("metallb"),
    spec: spec("metallb", mode) + {
      dependsOn: [{
        name: "infra-controllers"
      }]
    }
  }),
  kustomization({
    metadata: metadata("clusterissuers"),
    spec: spec("clusterissuers", mode) + {
      dependsOn: [{
        name: "infra-controllers"
      }]
    }
  }),
  kustomization({
    metadata: metadata("certs"),
    spec: spec("certs", mode) + {
      dependsOn: [{
        name: "infra-configs-clusterissuers"
      }]
    }
  }),
  kustomization({
    metadata: metadata("traefik"),
    spec: spec("traefik", mode) + {
      dependsOn: [{
        name: "infra-traefik"
      }, {
        name: "infra-configs-certs"
      }]
    }
  }),
  kustomization({
    metadata: metadata("vault"),
    spec: spec("vault", mode) + {
      dependsOn: [{
        name: "infra-configs-certs"
      }, {
        name: "infra-configs-traefik"
      }]
    }
  }),
  kustomization({
    metadata: metadata("vault-initializers"),
    spec: spec("vault-initializers", mode) + {
      dependsOn: [{
        name: "infra-vault"
      }]
    }
  }),
]
