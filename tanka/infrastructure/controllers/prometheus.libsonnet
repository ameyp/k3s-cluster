local vars = import 'variables.libsonnet';
local wirywolf = import 'wirywolf.libsonnet';
local secretName = 'alert-manager-config';

local volumeClaimTemplate = {
  volumeClaimTemplate: {
    spec: {
      storageClassName: "longhorn",
      resources: {
        requests: {
          storage: "2Gi"
        }
      }
    }
  }
};

function(mode='test') [
  wirywolf.secret.new({
    name: secretName,
    data: {
      "alertmanager.yaml": std.base64(importstr "files/prometheus/alertmanager.conf")
    }
  }), {
    apiVersion: "source.toolkit.fluxcd.io/v1beta2",
    kind: "HelmRepository",
    metadata: {
      name: "prometheus",
      namespace: vars.flux.namespace,
    },
    spec: {
      interval: "24h",
      url: "https://prometheus-community.github.io/helm-charts"
    }
  }, {
    apiVersion: "helm.toolkit.fluxcd.io/v2beta1",
    kind: "HelmRelease",
    metadata: {
      name: "prometheus-stack",
      namespace: vars.flux.namespace,
    },
    spec: {
      targetNamespace: vars.monitoring.namespace,
      interval: "30m",
      install: {
        createNamespace: true,
      },
      releaseName: "kube-prometheus-stack",
      chart: {
        spec: {
          chart: "kube-prometheus-stack",
          version: "43.1.0",
          sourceRef: {
            kind: "HelmRepository",
            name: "prometheus",
            namespace: vars.flux.namespace,
          },
          interval: "12h",
        },
      },
      values: std.mergePatch({
        alertmanager: {
          alertmanagerSpec: {
            useExistingSecret: true,
            configSecret: "",
            podMetadata: {
              labels: {
                "vault-injector": "enabled",
              },
              annotations: {
                "vault.hashicorp.com/agent-inject": "true",
                "vault.hashicorp.com/agent-pre-populate-only": "true",
                "vault.hashicorp.com/role": "alert-manager",
                "vault.hashicorp.com/service": wirywolf.get_endpoint(vars.vault.main.ingress.subdomain, mode),
                "vault.hashicorp.com/agent-inject-secret-slack-webhook-url": "tokens/data/slack",
                "vault.hashicorp.com/agent-inject-template-slack-webhook-url": |||
                  {{- with secret "tokens/data/slack" -}}
                  {{- .Data.data.alarm_webhook_url -}}
                  {{- end -}}
                |||,
              },
            },
            storage: volumeClaimTemplate
          },
        },
        prometheus: {
          prometheusSpec: {
            storage: volumeClaimTemplate
          },
          thanosRulerSpec: {
            storage: volumeClaimTemplate
          }
        },
        defaultRules: {
          rules: {
            etcd: false
          }
        },
        kubeEtcd: {
          enabled: false
        },
        kubeApiServer: {
          enabled: false
        },
        kubeControllerManager: {
          enabled: true,
          endpoints: [vars.cluster.controller_ip],
          service: {
            enabled: true,
            port: 10257,
            targetPort: 10257,
          },
        },
        kubeScheduler: {
          enabled: true,
          endpoints: [vars.cluster.controller_ip],
          service: {
            enabled: true,
            port: 10259,
            targetPort: 10259,
          },
        },
        kubeProxy: {
          enabled: true,
          endpoints: [vars.cluster.controller_ip],
        }
      }, if mode == 'test' then {
        prometheusOperator: {
          resources: {
            requests: {
              cpu: "100m"
            }
          },
          prometheusConfigReloader: {
            resources: {
              requests: {
                cpu: "100m"
              }
            },
          }
        }
      } else {})
    },
  },
]
