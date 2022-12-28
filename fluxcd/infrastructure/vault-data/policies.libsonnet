local vars = import "variables.libsonnet";

local policy = function(name, policyContent) {
  apiVersion: "redhatcop.redhat.io/v1alpha1",
  kind: "Policy",
  metadata: {
    name: name,
    namespace: vars.vault.namespace,
  },
  spec: {
    authentication: {
      path: "kubernetes",
      role: "operator",
    },
    policy: policyContent,
  },
};

function(mode) [
  policy("allow-tokens", |||
    path "tokens/*" {
      capabilities = ["read", "list"]
    }
|||)
]
