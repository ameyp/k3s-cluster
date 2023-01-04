local vars = import "variables.libsonnet";
local wirywolf = import "wirywolf.libsonnet";

function(mode, params) {
  "database-engines/postgresql.yaml": {
    apiVersion: "redhatcop.redhat.io/v1alpha1",
    kind: "DatabaseSecretEngineConfig",
    metadata: {
      name: "postgresql",
      namespace: vars.vault.namespace,
    },
    spec: {
      authentication: {
        path: "kubernetes",
        role: "operator",
      },
      pluginName: "postgresql-database-plugin",
      allowedRoles: ["*"],
      connectionURL: "postgresql://{{username}}:{{password}}@%s/postgres?sslmode=require" % params.postgresql.endpoint,
      rootCredentials: {
        usernameKey: "username",
        passwordKey: "password",
        secret: {
          name: "postgresql-initial-creds",
        },
      },
      path: params.postgresql.path,
      rootPasswordRotation: {
        enable: true,
        rotationPeriod: "168h", // 1 week
      },
      verifyConnection: true,
    },
  },
  "database-engines/immich.yaml": {
    apiVersion: "redhatcop.redhat.io/v1alpha1",
    kind: "DatabaseSecretEngineConfig",
    metadata: {
      name: "immich",
      namespace: vars.vault.namespace,
    },
    spec: {
      authentication: {
        path: "kubernetes",
        role: "operator",
      },
      pluginName: "postgresql-database-plugin",
      allowedRoles: ["*"],
      connectionURL: "postgresql://{{username}}:{{password}}@%s/immich?sslmode=require" % params.postgresql.endpoint,
      rootCredentials: {
        usernameKey: "username",
        passwordKey: "password",
        secret: {
          name: "immich-initial-creds",
        },
      },
      path: params.postgresql.path,
      rootPasswordRotation: {
        enable: true,
        rotationPeriod: "168h", // 1 week
      },
      verifyConnection: true,
    },
  },
  "database-engines/gitea.yaml": {
    apiVersion: "redhatcop.redhat.io/v1alpha1",
    kind: "DatabaseSecretEngineConfig",
    metadata: {
      name: "gitea",
      namespace: vars.vault.namespace,
    },
    spec: {
      authentication: {
        path: "kubernetes",
        role: "operator",
      },
      pluginName: "postgresql-database-plugin",
      allowedRoles: ["*"],
      connectionURL: "postgresql://{{username}}:{{password}}@%s/gitea?sslmode=require" % params.postgresql.endpoint,
      rootCredentials: {
        usernameKey: "username",
        passwordKey: "password",
        secret: {
          name: "gitea-initial-creds",
        },
      },
      path: params.postgresql.path,
      rootPasswordRotation: {
        enable: true,
        rotationPeriod: "168h", // 1 week
      },
      verifyConnection: true,
    },
  },
  "database-engines/mariadb.yaml": {
    apiVersion: "redhatcop.redhat.io/v1alpha1",
    kind: "DatabaseSecretEngineConfig",
    metadata: {
      name: "mariadb",
      namespace: vars.vault.namespace,
    },
    spec: {
      authentication: {
        path: "kubernetes",
        role: "operator",
      },
      pluginName: "mysql-database-plugin",
      allowedRoles: ["*"],
      connectionURL: "{{username}}:{{password}}@tcp(%s)/" % params.mariadb.endpoint,
      rootCredentials: {
        usernameKey: "username",
        passwordKey: "password",
        secret: {
          name: "mariadb-initial-creds",
        },
      },
      path: params.mariadb.path,
      rootPasswordRotation: {
        enable: true,
        rotationPeriod: "168h", // 1 week
      },
      verifyConnection: true,
    },
  },
}
