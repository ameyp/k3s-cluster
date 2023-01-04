local vars = import "variables.libsonnet";

function(mode, params) {
  "database-roles/postgresql-backups.yaml": {
    apiVersion: "redhatcop.redhat.io/v1alpha1",
    kind: "DatabaseSecretEngineRole",
    metadata: {
      name: "postgresql-backups",
      namespace: vars.vault.namespace,
    },
    spec: {
      authentication: {
        path: "kubernetes",
        role: "operator",
      },
      path: params.postgresql.path,
      dBName: "postgres",
      creationStatements: [
        "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' SUPERUSER;"
      ],
      maxTTL: "20m",
    }
  },
  "database-roles/postgresql-immich.yaml": {
    apiVersion: "redhatcop.redhat.io/v1alpha1",
    kind: "DatabaseSecretEngineStaticRole",
    metadata: {
      name: "immich",
      namespace: vars.vault.namespace,
    },
    spec: {
      authentication: {
        path: "kubernetes",
        role: "operator",
      },
      path: params.postgresql.path,
      dBName: "immich",
      username: "immich",
      rotationPeriod: 86400,
      rotationStatements: [
        "ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';"
      ],
      credentialType: "password",
      passwordCredentialConfig: {}
    }
  },
  "database-roles/postgresql-gitea.yaml": {
    apiVersion: "redhatcop.redhat.io/v1alpha1",
    kind: "DatabaseSecretEngineStaticRole",
    metadata: {
      name: "gitea",
      namespace: vars.vault.namespace,
    },
    spec: {
      authentication: {
        path: "kubernetes",
        role: "operator",
      },
      path: params.postgresql.path,
      dBName: "gitea",
      username: "gitea",
      rotationPeriod: 86400,
      rotationStatements: [
        "ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';"
      ],
      credentialType: "password",
      passwordCredentialConfig: {}
    }
  },
  "database-roles/mariadb-firefly.yaml": {
    apiVersion: "redhatcop.redhat.io/v1alpha1",
    kind: "DatabaseSecretEngineStaticRole",
    metadata: {
      name: "firefly",
      namespace: vars.vault.namespace,
    },
    spec: {
      authentication: {
        path: "kubernetes",
        role: "operator",
      },
      path: params.mariadb.path,
      dBName: "mariadb",
      username: "firefly",
      rotationPeriod: 86400,
      credentialType: "password",
      passwordCredentialConfig: {}
    },
  },
}
