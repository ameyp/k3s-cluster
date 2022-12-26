local vars = import "variables.libsonnet";

function(mode='test') {
  apiVersion: "helm.toolkit.fluxcd.io/v2beta1",
  kind: "HelmRelease",
  metadata: {
    name: "vault",
    namespace: vars.flux.namespace,
  },
  spec: {
    dependsOn: [
      {name: "vault-unsealer"},
    ],
    targetNamespace: vars.vault.namespace,
    install: {
      createNamespace: true,
    },
    interval: "30m",
    releaseName: "vault",
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
        tlsDisable: false,
      },
      ui: {
        enabled: true,
        externalPort: vars.vault.main.ingress.port,
        targetPort: vars.vault.main.ingress.port,
      },
      server: {
        extraArgs: "-config=/vault/secrets/server-config",
        // logLevel: "trace"
        annotations: {
          "vault.hashicorp.com/agent-inject": 'true',
          "vault.hashicorp.com/agent-pre-populate-only": 'true', # No sidecar
          "vault.hashicorp.com/role": 'vault',
          "vault.hashicorp.com/agent-configmap": 'vault-agent-autounseal',
        },
        ha: {
          enabled: true,
          replicas: 3,
          raft: {
            enabled: true,
            config: "",
          },
        },
        dataStorage: {
          size: "2Gi",
          storageClass: "longhorn",
        },
        auditStorage: {
          enabled: true,
          size: "1Gi",
          storageClass: "longhorn",
        },
        volumes: [{
          name: "vault-tls-internal",
          secret: {
            secretName: vars.vault.main.internalCertSecret,
          },
        }, {
          name: "vault-tls-web",
          secret: {
            secretName: vars.cluster.wildcard_cert_secret,
          },
        }],
        volumeMounts: [{
          mountPath: "/vault-tls-internal",
          name: "vault-tls-internal"
        }, {
          mountPath: "/vault-tls-web",
          name: "vault-tls-web"
        }],
        extraLabels: {
          "unseal-injector": "enabled",
        },
        # Changed from required to preferred because for some reason even a single pod fails to deploy on my test cluster.
        # And since I've changed this, might as well deploy all 3 even on my test cluster.
        affinity: {
          podAntiAffinity: {
            preferredDuringSchedulingIgnoredDuringExecution: [{
              weight: 100,
              podAffinityTerm: {
                labelSelector: {
                  matchLabels: {
                    "app.kubernetes.io/name": "vault",
                    "app.kubernetes.io/instance": "vault",
                    component: "server"
                  },
                },
                topologyKey: "kubernetes.io/hostname",
              }
            }]
          }
        }
      },
      injector: {
        enabled: true,
        webhook: {
          objectSelector: {
            matchLabels: {
              "vault-injector": "enabled"
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
