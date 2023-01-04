local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local vars = import "variables.libsonnet";
local secret = k.core.v1.secret;

function(mode) {
  "configuration/postgresql.yaml":
    // Create the secret containing the initial admin password
    secret.new("postgres-initial-creds", {}) +
    secret.metadata.withNamespace(vars.vault.namespace) +
    secret.withType("kubernetes.io/basic-auth") +
    secret.withStringData({
      "username": "vault",
      "password": "vaultpassword"
    }),
  "configuration/immich.yaml":
    // Create the secret containing the initial admin password
    secret.new("immich-initial-creds", {}) +
    secret.metadata.withNamespace(vars.vault.namespace) +
    secret.withType("kubernetes.io/basic-auth") +
    secret.withStringData({
      "username": "immich",
      "password": "immichpassword"
    }),
  "configuration/gitea.yaml":
    // Create the secret containing the initial admin password
    secret.new("gitea-initial-creds", {}) +
    secret.metadata.withNamespace(vars.vault.namespace) +
    secret.withType("kubernetes.io/basic-auth") +
    secret.withStringData({
      "username": "gitea",
      "password": "giteapassword"
    }),
  "configuration/mariadb.yaml":
    // Create the secret containing the initial admin password
    secret.new("mariadb-initial-creds", {}) +
    secret.metadata.withNamespace(vars.vault.namespace) +
    secret.withType("kubernetes.io/basic-auth") +
    secret.withStringData({
      "username": "vault",
      "password": "vaultpassword"
    }),
}
