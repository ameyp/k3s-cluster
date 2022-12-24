local vars = import 'variables.libsonnet';
local k = import 'k8s.libsonnet';

[
  {
    apiVersion: "batch/v1",
    kind: "Job",
    metadata: {
      name: "vault-unsealer-initializer",
      namespace: vars.vault.namespace,
    },
    spec: {
      template: {
        spec: {
          serviceAccount: vars.vault.initializer.service_account,
          restartPolicy: "Never",
          containers: [{
            name: "unsealer-init",
            image: "ameypar/k8s-vault-initializer:latest",
            args: ["-vault-for-autounseal"],
            env: [{
              name: "VAULT_ADDR",
              value: "https://%s" % k.get_endpoint(vars.vault.unsealer.ingress.subdomain),
            }]
          }]
        }
      }
    }
  }
]
