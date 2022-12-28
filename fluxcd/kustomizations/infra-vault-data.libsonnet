local wirywolf = import "wirywolf.libsonnet";

local kustomization = wirywolf.kustomization.new;
local metadata = import "./infra-configs-metadata.libsonnet";
local spec = import "./infra-configs-spec.libsonnet";

function(mode) [
  kustomization({
    metadata: metadata("vault-data"),
    spec: spec("vault-data", mode) + {
      dependsOn: [{
        name: "infra-vault-config-operator"
      }]
    }
  })
]
