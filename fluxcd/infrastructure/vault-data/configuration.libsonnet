local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local vars = import "variables.libsonnet";
local secret = k.core.v1.secret;

function(mode, secretName) {
  "configuration/secret.yaml":
    // Create the secret containing the initial admin password
    secret.new(secretName, {}) +
    secret.metadata.withNamespace(vars.vault.namespace) +
    secret.withType("kubernetes.io/basic-auth") +
    secret.withStringData({
      "username": "vault",
      "password": "vaultpassword"
    }),
}
