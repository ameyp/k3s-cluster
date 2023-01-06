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
        externalPort: 443,
        targetPort: vars.vault.main.ingress.port,
        serviceType: "LoadBalancer",
        loadBalancerIP: if mode == "test" then vars.vault.main.testLoadBalancerIP else vars.vault.main.loadBalancerIP,
        # This is necessary because requests to not-ready pods return a redirect to the api_addr of the cluster,
        # which is https://<active pod internal ip>:8200, which doesn't work with the LetsEncrypt cert.
        # This causes requests to occasionally fail with cert errors.
        activeVaultPodOnly: true,
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
          storageClass: vars.longhorn.singleReplicaStorageClass,
        },
        auditStorage: {
          enabled: true,
          size: "1Gi",
          storageClass: vars.longhorn.singleReplicaStorageClass,
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
      },
      serverTelemetry: {
        serviceMonitor: {
          enabled: true,
          selectors: {
            release: vars.monitoring.prometheus_stack_name,
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
