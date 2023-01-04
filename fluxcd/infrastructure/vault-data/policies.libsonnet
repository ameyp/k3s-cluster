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

function(mode) {
  "policies/allow-tokens.yaml": policy("allow-tokens", |||
    path "tokens/*" {
      capabilities = ["read", "list"]
    }
|||),

  "policies/allow-logins.yaml": policy("allow-logins", |||
    path "logins/*" {
      capabilities = ["read", "list"]
    }
|||),

  "policies/slack-webhooks.yaml": policy("slack-webhooks", |||
    path "tokens/data/slack" {
      capabilities = ["read"]
    }
|||),

  "policies/media.yaml": policy("media", |||
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
|||),

  "policies/operator.yaml": policy("operator", |||
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
  |||),
}
