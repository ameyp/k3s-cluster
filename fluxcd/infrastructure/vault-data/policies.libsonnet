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

  policy("allow-logins", |||
    path "logins/*" {
      capabilities = ["read", "list"]
    }
|||)

  policy("slack-webhooks", |||
    path "tokens/data/slack" {
      capabilities = ["read"]
    }
|||)

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
|||)

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

    path "postgres/*" {
      capabilities = ["create", "update", "list", "read", "delete"]
    }

    path "gitea/*" {
      capabilities = ["create", "update", "list", "read", "delete"]
    }

    path "mariadb/*" {
      capabilities = ["create", "update", "list", "read", "delete"]
    }
|||)
]
