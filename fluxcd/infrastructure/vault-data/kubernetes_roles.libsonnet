local vars = import "variables.libsonnet";

local role = function(name, params) {
  ["kubernetes-roles/%s.yaml" % name]: {
    apiVersion: "redhatcop.redhat.io/v1alpha1",
    kind: "KubernetesAuthEngineRole",
    metadata: {
      name: name,
      namespace: vars.vault.namespace,
    },
    spec: {
      authentication: {
        path: "kubernetes",
        role: "operator",
      },
      path: "kubernetes",
      policies: params.policies,
      targetServiceAccounts: params.serviceAccounts,
      targetNamespaces: {
        targetNamespaces: params.namespaces,
      },
    }
  },
};

function(mode)
  role("operator", {
    policies: ["operator"],
    serviceAccounts: ["default"],
    namespaces: [vars.vault.namespace]
  }) +
  role("media", {
    policies: ["media"],
    serviceAccounts: ["default"],
    namespaces: ["media"],
  }) +
  role("scraparr", {
    # TODO scope down
    policies: ["allow-tokens"],
    serviceAccounts: ["default"],
    namespaces: [vars.monitoring.namespace],
  }) +
  role("alert-manager", {
    policies: ["slack-webhooks"],
    serviceAccounts: ["prometheus-stack-kube-prom-alertmanager"],
    namespaces: [vars.monitoring.namespace],
  }) +
  role("redis", {
    # TODO scope down
    policies: ["allow-logins"],
    serviceAccounts: ["redis"],
    namespaces: [vars.databases.namespace],
  }) +
  role("kured", {
    policies: ["slack-webhooks"],
    serviceAccounts: ["kured"],
    namespaces: [vars.kured.namespace],
  }) +
  role("immich", {
    # TODO scope down
    policies: ["postgresql-immich", "allow-tokens", "allow-logins"],
    serviceAccounts: ["default"],
    namespaces: [vars.immich.namespace],
  }) +
  role("gitea", {
    # TODO scope down
    policies: ["postgresql-gitea", "allow-tokens", "allow-logins"],
    serviceAccounts: ["default"],
    namespaces: [vars.gitea.namespace],
  }) +
  role("firefly", {
    # TODO scope down
    policies: ["mariadb-firefly", "allow-tokens"],
    serviceAccounts: ["default"],
    namespaces: [vars.firefly.namespace],
  }) +
  role("nfs-backups", {
    policies: ["vault-snapshot", "create-backups", "postgresql-backups"],
    serviceAccounts: ["default"],
    namespaces: [
      "immich",
      "vault",
      "audiobookshelf",
      "media",
      "syncthing",
      "firefly",
      "postgresql",
      "gitea"
    ],
  })
