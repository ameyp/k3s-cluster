local vars = import "variables.libsonnet";

local policy = function(name, policyContent) {
  ["policies/%s.yaml" % name]: {
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
  },
};

function(mode)
  policy("allow-tokens", |||
    path "tokens/*" {
      capabilities = ["read", "list"]
    }
|||) +

  policy("allow-logins", |||
    path "logins/*" {
      capabilities = ["read", "list"]
    }
|||) +

  policy("slack-webhooks", |||
    path "tokens/data/slack" {
      capabilities = ["read"]
    }
|||) +

  policy("media", |||
    path "tokens/data/mullvad" {
      capabilities = ["read"]
    }
    path "tokens/data/sabnzbd" {
      capabilities = ["read"]
    }
    path "logins/data/tweaknews" {
      capabilities = ["read"]
    }
    path "logins/data/newsgroupdirect" {
      capabilities = ["read"]
    }
|||) +

  policy("operator", |||
    // path "auth/token/create" {
    //   capabilities = ["update"]
    // }

    path "sys/auth" {
      capabilities = ["create", "list", "read"]
    }

    path "auth/kubernetes/config" {
      capabilities = ["read"]
    }

    path "auth/kubernetes/role/*" {
      capabilities = ["create", "update", "list", "read", "delete"]
    }

    path "sys/mounts" {
      capabilities = ["list", "read"]
    }

    path "sys/mounts/*" {
      capabilities = ["create", "update", "list", "read", "delete"]
    }

    path "sys/policy/*" {
      capabilities = ["create", "update", "list", "read", "delete"]
    }

    path "databases/*" {
      capabilities = ["create", "update", "list", "read", "delete"]
    }

    path "gitea/*" {
      capabilities = ["create", "update", "list", "read", "delete"]
    }
  |||) +

  policy("mariadb-firefly", |||
    path "databases/mariadb/static-creds/firefly" {
      capabilities = ["read"]
    }
  |||) +

  policy("postgresql-immich", |||
    path "databases/postgresql/static-creds/firefly" {
      capabilities = ["read"]
    }
  |||) +

  policy("postgresql-gitea", |||
    path "databases/postgresql/static-creds/gitea" {
      capabilities = ["read"]
    }
  |||) +

  policy("postgresql-backups", |||
    path "databases/postgresql/creds/postgresql-backups" {
      capabilities = ["read"]
    }
  |||) +

  policy("vault-snapshot", |||
    path "sys/storage/raft/snapshot" {
      capabilities = ["read"]
    }
  |||) +

  policy("create-backups", |||
    path "tokens/data/restic" {
      capabilities = ["read"]
    }
    path "tokens/data/backblaze/*" {
      capabilities = ["read", "list"]
    }
  |||)
