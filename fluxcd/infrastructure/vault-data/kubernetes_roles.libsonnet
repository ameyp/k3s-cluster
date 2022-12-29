local vars = import "variables.libsonnet";

local role = function(name, params) {
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
  },
};

function(mode) [
  role("operator", {
    policies: ["operator"],
    serviceAccounts: ["default"],
    namespaces: [vars.vault.namespace]
  }),
  role("media", {
    policies: ["media"],
    serviceAccounts: ["default"],
    namespaces: ["media"],
  }),
  # TODO scope down
  role("scraparr", {
    policies: ["allow-tokens"],
    serviceAccounts: ["default"],
    namespaces: [vars.monitoring.namespace],
  }),
  role("alert-manager", {
    policies: ["slack-webhooks"],
    serviceAccounts: ["prometheus-stack-kube-prom-alertmanager"],
    namespaces: [vars.monitoring.namespace],
  }),
  # TODO scope down
  role("redis", {
    policies: ["allow-logins"],
    serviceAccounts: ["redis"],
    namespaces: [vars.redis.namespace],
  }),
  role("kured", {
    policies: ["slack-webhooks"],
    serviceAccounts: ["kured"],
    namespaces: [vars.kured.namespace],
  }),
]
