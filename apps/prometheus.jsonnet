local vars = import 'variables.libsonnet';
local k = import '../vendor/k8s.libsonnet';
local mode = std.extVar('mode');
local secretName = 'alert-manager-config';

function(mode='test') [
  k.secret.new({
    name: secretName,
    data: {
      "alertmanager.yaml": std.base64(importstr "files/prometheus/alertmanager.conf")
    }
  }),

  {
    apiVersion: "argoproj.io/v1alpha1",
    kind: "Application",
    metadata: {
      name: "prometheus-stack",
      namespace: vars.argo.namespace,
      annotations: {
        'argocd.argoproj.io/sync-wave': '1',
      },
    },
    spec: {
      project: vars.argo.project,
      source: {
        repoURL: 'https://prometheus-community.github.io/helm-charts',
        targetRevision: '39.5.0',
        chart: 'kube-prometheus-stack',
        helm: {
          values: (importstr "files/prometheus/values.yaml") % {
            controller_ip: vars.cluster.controller_ip,
            config_secret: "",
            vault_address: vars.vault.address,
          },
        },
      },
      destination: {
        server: 'https://kubernetes.default.svc',
        namespace: vars.monitoring.namespace,
      },
      syncPolicy: {
        automated: {
          selfHeal: true,
        },
        syncOptions: [
          'Validate=false',
          'CreateNamespace=true',
        ],
        retry: {
          limit: 2,
          backoff: {
            duration: '5s',
            factor: 2,
            maxDuration: '3m',
          },
        },
      },
    },
  }
]
