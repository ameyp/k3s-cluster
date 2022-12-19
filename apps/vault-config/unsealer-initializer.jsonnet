local k = import 'k8s.libsonnet';
local vars = import 'variables.libsonnet';
local service_account = 'vault-unsealer-init';

[
  k.service_account.new({
    name: service_account,
    namespace: vars.vault_unsealer.namespace,
  }),
  k.role.new({
    name: service_account,
    namespace: vars.vault_unsealer.namespace,
    rules: [{
      apiGroups: [""],
      resources: ["secrets"],
      verbs: ["*"]
    }]
  }),
  k.role_binding.new({
    name: service_account,
    namespace: vars.vault_unsealer.namespace,
    roleRef: service_account,
    subjects: [{
      kind: "ServiceAccount",
      name: service_account
    }]
  }),

  {
    apiVersion: "batch/v1",
    kind: "Job",
    metadata: {
      name: "vault-unsealer-initializer",
      namespace: vars.vault_unsealer.namespace,
    },
    spec: {
      template: {
        spec: {
          serviceAccount: service_account,
          restartPolicy: "Never",
          containers: [{
            name: "init",
            image: "ameypar/k8s-vault-initializer:latest",
            env: [{
              name: "VAULT_ADDR",
              value: "https://%s" % k.get_endpoint(vars.vault_unsealer.ingress.subdomain),
            }]
          }]
        }
      }
    }
  }
]
