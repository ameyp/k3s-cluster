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
        secret: {
          name: params.postgresql.passwordSecret,
        },
      },
      path: params.postgresql.path,
      rootPasswordRotation: {
        enable: true,
        rotationPeriod: "168h", // 1 week
      }
    }
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
        secret: {
          name: params.mariadb.passwordSecret,
        },
      },
      path: params.mariadb.path,
      rootPasswordRotation: {
        enable: true,
        rotationPeriod: "168h", // 1 week
      }
    }
  },
}
