local vars = import 'variables.libsonnet';
local k = import 'k8s.libsonnet';

[
  {
    apiVersion: "batch/v1",
    kind: "Job",
    metadata: {
      name: "vault-main-initializer",
      namespace: vars.vault.namespace,
    },
    spec: {
      template: {
        spec: {
          serviceAccount: vars.vault.initializer.service_account,
          restartPolicy: "Never",
          containers: [{
            name: "main-init",
            image: "ameypar/k8s-vault-initializer:latest",
            env: [{
              name: "VAULT_ADDR",
              value: "https://%s" % k.get_endpoint(vars.vault.main.ingress.subdomain),
            }]
          }]
        }
      }
    }
  }
]
