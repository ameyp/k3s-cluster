local vars = import "variables.libsonnet";

function(mode='test') {
  apiVersion: "helm.toolkit.fluxcd.io/v2beta1",
  kind: "HelmRelease",
  metadata: {
    name: "vault-unsealer",
    namespace: vars.flux.namespace,
  },
  spec: {
    targetNamespace: vars.vault.namespace,
    install: {
      createNamespace: true,
    },
    interval: "30m",
    releaseName: "vault-unsealer",
    chart: {
      spec: {
        chart: "vault",
        version: "0.21.0",
        sourceRef: {
          kind: "HelmRepository",
          name: "hashicorp",
          namespace: vars.flux.namespace,
        },
        interval: "12h",
      },
    },
    values: std.mergePatch({
      global: {
        tlsDisable: false
      },
      ui: {
        enabled: true,
        externalPort: vars.vault.unsealer.ingress.port,
        targetPort: vars.vault.unsealer.ingress.port,
        serviceType: "LoadBalancer",
        loadBalancerIP: if mode == "test" then vars.vault.unsealer.testLoadBalancerIP else vars.vault.unsealer.loadBalancerIP,
      },
      server: {
        // logLevel: "trace"
        standalone: {
          enabled: true,
          config: |||
            ui = true
            listener "tcp" {
              tls_disable = 0
              tls_cert_file = "/vault-tls-web/tls.crt"
              tls_key_file = "/vault-tls-web/tls.key"
              address = "[::]:8200"
              cluster_address = "[::]:8201"
            }
            storage "file" {
              path = "/vault/data"
            }
          |||,
        },
        dataStorage: {
          size: "1Gi",
          storageClass: "longhorn"
        },
        auditStorage: {
          enabled: true,
          size: "1Gi",
          storageClass: "longhorn"
        },
        volumes: [{
          name: "vault-tls-web",
          secret: {
            secretName: vars.cluster.wildcard_cert_secret,
          }
        }],
        volumeMounts: [{
          mountPath: "/vault-tls-web",
          name: "vault-tls-web"
        }],
        extraEnvironmentVars: {
          VAULT_CACERT: "/vault-tls-web/tls.crt"
        }
      },
      injector: {
        // logLevel: "trace",
        enabled: true,
        webhook: {
          objectSelector: {
            matchLabels: {
              "unseal-injector": "enabled"
            }
          }
        }
      }
    }, if mode == 'test' then {
      injector: {
        agentDefaults: {
          cpuRequest: "100m"
        }
      },
      server: {
        resources: {
          requests: {
            cpu: "100m"
          }
        }
      }
    } else {}),
  },
}
