local vars = import "variables.libsonnet";

function(mode, params) {
  "database-mounts/postgresql.yaml": {
    apiVersion: "redhatcop.redhat.io/v1alpha1",
    kind: "SecretEngineMount",
    metadata: {
      name: params.postgresql.name,
      namespace: vars.vault.namespace,
    },
    spec: {
      authentication: {
        path: "kubernetes",
        role: "operator",
      },
      type: "database",
      path: params.path
    }
  },
  "database-mounts/mariadb.yaml": {
    apiVersion: "redhatcop.redhat.io/v1alpha1",
    kind: "SecretEngineMount",
    metadata: {
      name: params.mariadb.name,
      namespace: vars.vault.namespace,
    },
    spec: {
      authentication: {
        path: "kubernetes",
        role: "operator",
      },
      type: "database",
      path: params.path
    }
  }
}
