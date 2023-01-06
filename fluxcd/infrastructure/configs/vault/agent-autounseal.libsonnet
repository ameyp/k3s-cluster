local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';

function(mode='test') [{
  apiVersion: "v1",
  kind: "ConfigMap",
  metadata: {
    name: "vault-agent-autounseal",
    namespace: vars.vault.namespace,
  },
  data: {
    "config-init.hcl": |||
      exit_after_auth = true

      pid_file = "/home/vault/pidfile"

      auto_auth {
        method "kubernetes" {
          mount_path = "auth/kubernetes"
          config = {
            role = "autounseal"
          }
        }
      }

      template {
        destination = "%(configFilePath)s"
        contents = <<-EOT
          disable_mlock = true
          // log_level = "debug"
          ui = true
          // For peers in the raft to talk to each other
          listener "tcp" {
            tls_disable = 0
            tls_cert_file = "/vault-tls-internal/tls.crt"
            tls_key_file = "/vault-tls-internal/tls.key"
            address = "[::]:8200"
            cluster_address = "[::]:8201"
          }
          // For clients to talk to the cluster
          listener "tcp" {
            tls_disable = 0
            tls_cert_file = "/vault-tls-web/tls.crt"
            tls_key_file = "/vault-tls-web/tls.key"
            address = "[::]:8300"
            cluster_address = "[::]:8301"
            telemetry {
              unauthenticated_metrics_access = "true"
            }
          }
          seal "transit" {
            address = "%(unsealerEndpoint)s"
            disable_renewal = "false"
            key_name = "autounseal"
            mount_path = "transit/"
            tls_skip_verify = "true"
            {{ with secret "auth/token/lookup-self" -}}
            token = "{{ .Data.id }}"
            {{ end }}
          }
          storage "raft" {
            path = "/vault/data"
            retry_join {
              leader_api_addr = "https://vault-0.vault-internal:8200"
              leader_ca_cert_file = "/vault-tls-internal/tls.crt"
            }
            retry_join {
              leader_api_addr = "https://vault-1.vault-internal:8200"
              leader_ca_cert_file = "/vault-tls-internal/tls.crt"
            }
            retry_join {
              leader_api_addr = "https://vault-2.vault-internal:8200"
              leader_ca_cert_file = "/vault-tls-internal/tls.crt"
            }
          }
          service_registration "kubernetes" {}
          telemetry {
            prometheus_retention_time = "30s",
            disable_hostname = true
          }
          EOT
      }
    ||| % {
      configFilePath: vars.vault.main.configFilePath,
      unsealerEndpoint: "https://%s" % [wirywolf.get_endpoint(vars.vault.unsealer.ingress.subdomain, mode)],
    }
  }
}]
