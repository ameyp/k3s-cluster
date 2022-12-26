local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';

function(mode='test') [{
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
            value: "https://%s" % wirywolf.get_endpoint(vars.vault.main.ingress.subdomain, mode),
          }]
        }]
      }
    }
  }
}]
